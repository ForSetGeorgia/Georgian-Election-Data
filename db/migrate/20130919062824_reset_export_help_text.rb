# encoding: UTF-8
class ResetExportHelpText < ActiveRecord::Migration
  def up
    PageTranslation.transaction do
      p = PageTranslation.where(:id => 5)
      p.first.description = 'You can export the map in two ways.

  1 - SVG. You can click on the button labeled \'SVG\' to download an SVG image of the map. SVG is similar to an image, but it contains layers that you can interact with. For example, you can change colors, add text, move shapes, etc. You can use a free application called Inkscape to edit these SVG files and save them into different formats like PDF and PNG.

  2 - XLS/CSV. You can click on the button labeled \'XLS\' or \'CSV\' to download the data into a spreadsheet. This data download will include all data for the selected event at the selected map level. For example, if you are looking at 2008 Presidential Elections at the Region level, the \'XLS\' button will download data for 2008 Presidential Elections for all Regions. Note - To be able to view the Georgian language spreadsheets in Excel, you must click on the \'XLS\' button.'
      p.first.save

      p = PageTranslation.where(:id => 6)
      p.first.description = 'რუკის ექსპორტი შესაძლებელია ორი სახით.

1 - SVG. რუკის სურათად გადმოსაწერად დააჭირეთ მარჯვენა ქვედა კუთხეში ღილაკს "SVG". SVG-ით იმავე გამოსახულებას მიიღებთ, რაც რუკაზეა, ამასთან მას აქვს დამატებითი ფუნქციები რითაც შეგიძლიათ ისარგებლოთ. მაგალითად, შეგიძლიათ შეცვალოთ ფერები, დაამატოთ ტექსტი, გადაანაცვლოთ საზღვრები და ა.შ. ამისათვის შეგიძლიათ გამოიყენოთ უფასო აპლიკაცია სახელად "Inkscape", განახორციელოთ ცვლილებები SVG ფაილში და შეინახოთ სხვადასხვა ფორმატში როგორიცაა PDF ან PNG.

2 - XLS/CSV. მონაცემების ცხრილის ფორმატში გადმოსაწერად დააჭირეთ ღილაკს "XLS" ან "CSV". გადმოწერილი მონაცემები იქნება არჩეული საკითხისა და რუკის შესაბამისი ზონის ამსახველი. მაგალითად, თუ უყურებთ 2008 წლის საპრეზიდენტო არჩევნებს რეგიონალურ დონეზე, "XLS" ღილაკი გადმოწერს 2008 წლის საპრეზიდენტო არჩევნების მონაცემებს საქართველოს ყველა რეგიონისთვის. შენიშვნა: Excel-ის ფორმატში ქართულ ენაზე ცხრილის სანახავად დააჭირეთ "XLS" ღილაკს.'
      p.first.save

    end    
  end

  def down
    PageTranslation.transaction do
      p = PageTranslation.where(:id => 5)
      p.first.description = 'You can click on the button labeled \'Download SVG\' to download an SVG image of the map. SVG is similar to an image, but it contains layers that you can interact with. For example, you can change colors, add text, move shapes, etc. You can use a free application called Inkscape to edit these SVG files and save them into different formats like PDF and PNG.'
      p.first.save

      p = PageTranslation.where(:id => 6)
      p.first.description = 'რუკის სურათად გადმოსაწერად დააჭირეთ მარჯვენა ქვედა კუთხეში ღილაკს "Download SVG". SVG-ით იმავე გამოსახულებას მიიღებთ, რაც რუკაზეა, ამასთან მას აქვს დამატებითი ფუნქციები რითაც შეგიძლიათ ისარგებლოთ. მაგალითად, შეგიძლიათ შეცვალოთ ფერები, დაამატოთ ტექსტი, გადაანაცვლოთ საზღვრები და ა.შ. ამისათვის შეგიძლიათ გამოიყენოთ უფასო აპლიკაცია სახელად "Inkscape", განახორციელოთ ცვლილებები SVG ფაილში და შეინახოთ სხვადასხვა ფორმატში როგორიცაა PDF ან PNG.'
      p.first.save

    end    
  end
end

