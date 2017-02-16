import urllib.request
from multiprocessing.pool import ThreadPool

def get_redirected_url(url):
    opener = urllib.request.build_opener(urllib.request.HTTPRedirectHandler)
    request = opener.open(url)
    return request.url


with urllib.request.urlopen("https://dl.dropboxusercontent.com/u/9526991/zocdocurls.csv") as response:
  urls = [url.strip().decode("utf-8")  for url in response.readlines()]


results = ThreadPool(20).imap_unordered(get_redirected_url, urls)



