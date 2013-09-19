# encoding: UTF-8
class AddAboutText < ActiveRecord::Migration
  def up
    page = Page.create(:name => 'about_landing')
    page.page_translations.create(:locale => 'ka', :title => 'შესახებ', :description => "საქართველოს არჩევნების მონაცემები წარმოადგენს 2008 წლის შემდეგ საქართველოში ჩატარებული არჩევნების შედეგებს. თითოეული არჩევნების დეტალური შესწავლა შესაძლებელია ისეთი ინდიკატორების მიხედვით, როგორიც  არის აქტივობა, არჩევნების შედეგები, ინდივიდუალური პარტიის შედეგები და სხვა. მონაცემების ვიზუალიზება რუკებისა და ცხრილის ფორმატში ქმნის შესაძლებლობას, გაანალიზდეს არჩევნების შედეგების გეოგრაფიული განაწილება ოლქებისა და საარჩევნო უბნების მიხედვით. ამგვარად, თქვენ გეძლევათ ინსტრუმენტები მონაცემების მრავალმხრივი გამოყენებისთვის, როგორიც არის იმ ტერიტორიული ერთეულების იდენტიფიცირება, სადაც ამომრჩეველთა აქტივობა დაბალია და სადაც ამომრჩეველთა მობილიზაციისკენ მიმართული ღონისძიებები შესაძლოა უფრო ეფექტური იყოს. 

არჩევნების შედეგებთან ერთად, თქვენ შეგიძლიათ, როგორც რუკის, ასევე ცხრილის ფორმატში, გაეცნოთ ამომრჩეველთა სიის ანალიზს 2006 წლიდან დღემდე, ისეთი ინდიკატორების გამოყენებით, როგორიც არის, ამომრჩეველთა რაოდენობა, საშუალო ასაკი, დუბლირებული ამომრჩევლები.")
    
    page.page_translations.create(:locale => 'en', :title => 'About', :description => "Georgian Election Data brings to you the results of each election in Georgia since 2008. You can explore each election in detail using a variety of indicators such as turnout, overall results, individual party results, and much more. Visualizing the data using maps as well as in tabular format allows you to explore and analyze how election results are distributed geographically by district and precinct. In this way, you have the tools to explore data for different applications, such as identifying areas of low turnout to target voter mobilization efforts at the street level, where they are most effective.

In addition to election results, you can also explore both using the map and in tabular format the data of a number of voters lists beginning in 2006, including indicators such as the total number of voters, average age of voters, and duplications.")
  end

  def down
    Page.where(:name => 'about_landing').destroy
  end
end
