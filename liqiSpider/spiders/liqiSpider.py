import scrapy

class liqiItem(scrapy.Item):
    source = scrapy.Field()
    title = scrapy.Field()
    date = scrapy.Field()
    tools = scrapy.Field()
    links = scrapy.Field()
    
    
class LiqiSpider(scrapy.Spider):
    name = "liqi"

    def start_requests(self):
        urls = ['http://liqi.io/creators/']
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse)

    def parse(self, response):
        links = response.css("div.clean-my-archives ul li a::attr(href)").extract()
        for link in links:
            request = scrapy.Request(url=link, callback=self.parseLink)
            yield request

    def parseLink(self, response):
        item = liqiItem()
        item['source'] = response.url
        post = response.css('main.site-main div.container article')
        item['title'] = post.css("header.entry-header h1.entry-title::text").extract()
            
        if post.css("time.updated::text").extract() == "":
            item['date'] = post.css("time.updated::text").extract()
        else:
            item['date'] = post.css("time.entry-date.published::text").extract()
            
        tools = []
        links = []
        for con in post.css('div.entry-content a'):
            t = con.css("a::text").extract()
            l = con.css("a::attr(href)").extract()
            if len(t) > 0 and len(l) > 0:
                tools += t[:1]
                links += l[:1]
            
        item['tools'] = ";".join(tools)
        item['links'] = ";".join(links)
        yield item
            
            
## run the spider on shell
## scrapy crawl liqi -t csv -o "liqi.csv" --loglevel=INFO
