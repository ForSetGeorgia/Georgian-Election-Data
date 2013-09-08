#!/usr/bin/env ruby
# encoding: utf-8

# format district profile data into structured HTML for Election Data Portal

# Example
#
# ./district_profile_parser2html.rb georgian input_csv_file

require 'csv'

language = ARGV[0]
input_csv = ARGV[1]
date = Time.now.strftime("%Y%m%d-%H%M")
output_csv = "dist_prof_#{language}_pars2html_#{date}.csv"
output_html = "output.html"

def lastN(n)
  self[-n,n]
end

CSV.open(output_csv, "wb") do |ocsv|

  CSV.foreach(input_csv) do |icsv|
    if icsv[1].downcase == 'english'
      district = icsv[2]
      p1 = icsv[3].sub("Tbilisi", "<span>Tbilisi</span>").sub("#{district} Municipality", "<span>#{district} Municipality</span>")
      p2 = icsv[4]
      p3 = icsv[5].sub("Population of Tbilisi (total)", "<span>Population of Tbilisi (total)</span>")
      p4 = icsv[6].sub("Population of Tbilisi according to gender:", "<span>Population of Tbilisi according to gender:</span")
      p5 = icsv[7].sub("Population of Tbilisi according to residence:", "<span>Population of Tbilisi according to residence:</span>")
      p6 = icsv[8].sub("Population of Tbilisi according to ethnicity:", "<span>Population of Tbilisi according to ethnicity:</span>")
      p7 = icsv[9].sub("Size of the Tbilisi territory", "<span>Size of the Tbilisi territory</span>").sub("km2", "km<sup>2</sup>")
      p8 = icsv[10].sub("*the numbers are indicated according to the 2002 nation-wide census. The information about administrational-territorial division was provided by the Ministry of Regional Development and Infrastructure of Georgia on July 17, 2013.", "<span>*the numbers are indicated according to the 2002 nation-wide census. The information about administrational-territorial division was provided by the Ministry of Regional Development and Infrastructure of Georgia on July 17, 2013.</span>")
      if icsv[13] == "Yes"
        p9 = "  <p>The following villages in <span>#{district}</span> are occupied:\n  <ul>\n"
        villages = icsv[15].split("\n")
        
        villages.each do |village|
          p9 << "    <li>#{village}</li>\n"
        end
        
        p9 << "  </ul>"
        
      end

html = <<eos
<p>#{p1}</p>
<p>#{p2}</p>
<ul>
  <li>#{p3}</li>
  <li>#{p4}</li>
  <li>#{p5}</li>
  <li>#{p6}</li>
  <li>#{p7}</li>
</ul>
#{p9 if p9}
<p>#{p8}</p>
eos

      File.open(output_html, 'a') { |file| file.write(html) }   
      ocsv << [icsv[1], icsv[2], html]
      
    elsif icsv[1].downcase == 'georgian'
      district = icsv[2]
      
      def self.genativize(word)
        if word[-1] == 'ა' or word[-1] == 'ი' or word[-1] == 'ე'
          word = word[0..-2]
          word << 'ის'
        elsif word[-1] == 'ო' 
          word << 'ს'
        end
        word
      end
      
      def self.sheize(word)
        if word[-1] == 'ი'
          word = word[0..-2]
          word << 'ში'
        elsif word[-1] == 'ა'or word[-1] == 'ო' or word[-1] == 'ე' or word[-1] == 'უ'
          word << 'ში'
        end
        word
      end
      
      gen_dist = genativize(district)
      
      p1 = icsv[3].sub("თბილისი", "<span>თბილისი</span>").sub("#{gen_dist} მუნიციპალიტეტი", "<span>#{gen_dist} მუნიციპალიტეტი</span>")
      p2 = icsv[4]
      p3 = icsv[5].sub("მოსახლეობა (სულ)", "<span>მოსახლეობა (სულ)</span>") if icsv[12] != "Yes"
      p3 = icsv[5].sub("თბილისის მოსახლეობა (სულ)", "<span>თბილისის მოსახლეობა (სულ)</span>") if icsv[12] == "Yes"
      p4 = icsv[6].sub("მოსახლეობა სქესის მიხედვით:", "<span>მოსახლეობა სქესის მიხედვით:</span>") if icsv[12] != "Yes"
      p4 = icsv[6].sub("თბილისის მოსახლეობა სქესის მიხედვით:", "<span>თბილისის მოსახლეობა სქესის მიხედვით:</span>") if icsv[12] == "Yes"
      p5 = icsv[7].sub("მოსახლეობა დასახლების ტიპის მიხედვით:", "<span>მოსახლეობა დასახლების ტიპის მიხედვით:</span>") if icsv[12] != "Yes"
      p5 = icsv[7].sub("თბილისის მოსახლეობა დასახლების ტიპის მიხედვით:", "<span>თბილისის მოსახლეობა დასახლების ტიპის მიხედვით:</span>") if icsv[12] == "Yes"
      p6 = icsv[8].sub("მოსახლეობა ეროვნების მიხედვით:", "<span>მოსახლეობა ეროვნების მიხედვით:</span>") if icsv[12] != "Yes"
      p6 = icsv[8].sub("თბილისის მოსახლეობა ეროვნების მიხედვით:", "<span>თბილისის მოსახლეობა ეროვნების მიხედვით:</span>") if icsv[12] == "Yes"
      p7 = icsv[9].sub("ტერიტორია", "<span>ტერიტორია</span>").sub("კმ2", "კმ<sup>2</sup>") if icsv[12] != "Yes"
      p7 = icsv[9].sub("თბილისის ტერიტორია", "<span>თბილისის ტერიტორია</span>").sub("კმ2", "კმ<sup>2</sup>") if icsv[12] == "Yes"
      p8 = icsv[10]
      
      if icsv[13] == "Yes"
        p9 = "  <p>შემდეგი სოფლები <span>#{sheize(district)}</span> ოკუპირებულია:</p>\n  <ul>\n"
        villages = icsv[15].split("\n")
        
        villages.each do |village|
          p9 << "    <li>#{village}</li>\n"
        end
        
        p9 << "  </ul>"
        
      end

html = <<eos
<p>#{p1}</p>
<p>#{p2}</p>
<ul>
  <li>#{p3}</li>
  <li>#{p4}</li>
  <li>#{p5}</li>
  <li>#{p6}</li>
  <li>#{p7}</li>
</ul>
#{p9 if p9}
<p>#{p8}</p>
eos

      File.open(output_html, 'a') { |file| file.write(html) }   
      ocsv << [icsv[1], icsv[2], html]
    end
   
  end

end
