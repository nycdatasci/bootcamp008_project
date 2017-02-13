from lxml import etree
import pandas as pd

with open('../data/allagents.xml') as f:
    agents = etree.tostring(etree.parse(f))
    f.close()

agents_xml = etree.XML(agents)
vals = [x.text for x in agents_xml.xpath('.//String')]
types = [y.text for y in agents_xml.xpath('.//Type')]
df = pd.DataFrame(data=list(zip(vals, types)), columns=['value', 'type'])

f = open('data/allagents.txt', 'a')
for ua in list(df[df['type'] == 'B']['value']):
    f.writelines(ua + '\n')
