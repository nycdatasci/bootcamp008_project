# -*- coding: utf-8 -*-
from scrapy import Spider, Request, Selector
from jobs.items import JobPosting
import re, datetime, json

amazon_headers = {
    'Host': 'www.amazon.jobs',
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate, br',
    'Content-Type': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
    'DNT': '1',
    'Connection': 'keep-alive'
}

base_url = 'https://www.amazon.jobs/en/search?base_query=data+scientist&sort=relevant&result_limit=100&offset='

class GetJobsSpider(Spider):
    name = "amazon"
    allowed_domains = ["amazon.jobs"]
    
    def start_requests(self):
        return [Request(base_url + '0', meta = {'offset': 0},
                    headers = amazon_headers, callback = self.parse_list)]
        
    custom_settings = {
        'ITEM_PIPELINES': {
            'jobs.pipelines.JobsPipeline': 100
        }
    }

    def parse_list(self, response):
        json_list = json.loads(response.body)
        count = int(json_list.get('hits', 0))
        self.logger.debug('Got %d results.' % count)
        offset = response.meta['offset']
        for job_json in json_list.get('jobs', []):
            try:
                country = job_json.get('country_code', None)
                if country is None:
                    country = job_json.get('location', '')
                if re.match('US.*', country) is None:
                    self.logger.debug('Country is not USA: "' + country + '". Skipping...')
                    continue
                job_id = job_json['id']
                title = job_json['title']
                location = job_json.get('location', '')
                date_posted = job_json.get(u'posted_date', '')
                if len(date_posted) > 0:
                    try:
                        date_posted = datetime.datetime.strptime(date_posted, '%B %d, %Y').date()
                    except:
                        date_posted = datetime.datetime.strptime(date_posted, '%B  %d, %Y').date()
                department = job_json.get('job_category', '')
                role_description = job_json.get(u'description', '')
                url = response.urljoin(job_json.get(u'job_path', '/en/jobs/' + job_json.get(u'id_icims', '')))
                listings = []
                for key, value in [(u'basic_qualifications', 'Basic Qualifications'),
                        (u'preferred_qualifications', 'Preferred Qualifications')]:
                    if key not in job_json:
                        continue
                    this_listing = {}
                    this_listing['type'] = value
                    this_listing['elements'] = [x for x in [elem.replace(u'\u2022', '').strip() for elem in re.split('<br/>\\s*\u2022', job_json[key].strip())] if len(x) > 0]
                    listings.append(this_listing)
                
                posting = JobPosting()
                posting['job_id'] = job_id
                posting['title'] = title.strip()
                posting['department'] = department.strip()
                posting['location'] = location.strip()
                posting['date_posted'] = date_posted
                posting['time_scraped'] = datetime.datetime.now()
                posting['url'] = url
                posting['role_description'] = role_description.strip()
                posting['listings'] = listings
                yield posting
            except Exception as excpt:
                self.logger.error('Unable to parse Amazons\'s: '\
                    + str(job_json) + '\n' + str(excpt))
        if offset + 100 < count:
            yield Request(base_url + str(offset + 100), meta = {'offset': offset + 100},
                    headers = amazon_headers, callback = self.parse_list)
        else:
            self.logger.debug('Not submitting any more requests. offset = %d, count = %d' %(offset, count))
