require 'nokogiri'
require 'rest-client'
require 'csv'


class Car
    def initialize(brand, title, year, fuel)
        @brand = brand
        @title = title
        @year = year
        @fuel = fuel
    end
    def returnBrand
        return "#@brand"
    end
    def returnTitle
        return "#@title"
    end
    def returnYear
        return "#@year"
    end
    def returnFuel
        return "#@fuel"
    end
    class << self
        attr_accessor :variable
     end
end

$pageVar = 1

def getTitle(nn)
        htm2l = RestClient.get("https://www.otomoto.pl/osobowe?page=#{$pageVar.to_s}")
        doc = Nokogiri::HTML.parse(htm2l)
        doc.css("p.ooa-1eoi6yd").remove
        doc.css("p.ooa-1eew6k").remove
        input = doc.css('.ev7e6t815, .oa-1xvnx1e, .er34gjf0').css('a')
        noArray = input.xpath("text()")
        $array = noArray.map{|t| t.text.strip}
    return $array[nn]
end

def getBrand(nn)
        htm2l = RestClient.get("https://www.otomoto.pl/osobowe?page=#{$pageVar.to_s}")
        doc = Nokogiri::HTML.parse(htm2l)
        docText = doc.text
        testBrand = docText.scan(/Marka pojazdu(.*?)__typename/m).to_s
        brand = testBrand.scan(/:(.*?)",/m)
        brandFinal = brand.join(", ")
        $brandSuperFinal = brandFinal.scan(/"(.*?)[^a-zA-Z]/m)
        $brandSuperFinal.pop(8)
    return $brandSuperFinal[nn]
end

def getYear(nn)
        htm2l = RestClient.get("https://www.otomoto.pl/osobowe?page=#{$pageVar.to_s}")
        doc = Nokogiri::HTML.parse(htm2l)
        docText = doc.text
        testNumber = docText.scan(/Rok produkcji(.*?)__typename/m).to_s
        $year = testNumber.scan(/\b\d{4}\b/)
    return $year[nn]
end

def getFuelType(nn)
        htm2l = RestClient.get("https://www.otomoto.pl/osobowe?page=#{$pageVar.to_s}")
        doc = Nokogiri::HTML.parse(htm2l)
        docText = doc.text
        testFuel = docText.scan(/Rodzaj paliwa(.*?)__typename/m).to_s
        fuel = testFuel.scan(/":(.*?)",/m).to_s
        fuelFinal = fuel.scan(/"(.*?)[^a-zA-Z]/m).to_s
        $fuelSuperFinal = fuelFinal.scan(/\b(.*?)\b"]/m)  
        $fuelSuperFinal.pop(6)
    return $fuelSuperFinal[nn]
end

# def getModel()
    # doc = Nokogiri::HTML.parse($html)
    # docText = doc.text
    # testModel = docText.scan(/Rodzaj paliwa(.*?)__typename/m).to_s
    # puts docText
# 
# end

headers = ["Brand", "Title", "Year", "Fuel"]
CSV.open("results.csv", "w", write_headers: true, headers: headers) do |csv|

while $pageVar<=5
    n=0
    while n<32
        car1 = Car.new(getBrand(n), getTitle(n), getYear(n), getFuelType(n))
        brand2 = car1.returnBrand.tr('"', '').tr('[', '').tr(']','')
        fuel2 = car1.returnFuel.tr('"', '').tr('[', '').tr(']','')
        row = [brand2, car1.returnTitle, car1.returnYear, fuel2]
        csv << row
        n += 1
    end
    $pageVar+=1
end
end
