class AddMoreShapeTypes < ActiveRecord::Migration
  def up
    # add 'Tbilisi Majoritarian District', 'Tbilisi Majoritarian Precinct'
    # - this is so we can now change the parent to be major district for tbilisi major district

    st = ShapeType.create(:id => 11, :ancestry => '1/2/3/5')
    st.shape_type_translations.create(:locale=>"ka", :name_singular=>"თბილისი მაჟორიტარიული ოლქი", :name_plural=>"თბილისი მაჟორიტარიული ოლქები",
      name_singular_possessive: 'თბილისის მაჟორიტარული ოლქის', name_singular_in: 'თბილისის მაჟორიტარულ ოლქში')
    st.shape_type_translations.create(:locale=>"en", :name_singular=>"Tbilisi Majoritarian District", :name_plural=>"Tbilisi Majoritarian Districts",
      name_singular_possessive: 'Tbilisi Majoritarian District', name_singular_in: 'in Tbilisi Majoritarian District')


    st = ShapeType.create(:id => 12, :ancestry => '1/2/3/5/11', is_precinct: true)
    st.shape_type_translations.create(:locale=>"ka", :name_singular=>"თბილისი მაჟორიტარიული საუბნო", :name_plural=>"თბილისი მაჟორიტარიული საუბნოები",
      name_singular_possessive: 'თბილისის მაჟორიტარული უბნის', name_singular_in: 'თბილისის მაჟორიტარულ უბანში')
    st.shape_type_translations.create(:locale=>"en", :name_singular=>"Tbilisi Majoritarian Precinct", :name_plural=>"Tbilisi Majoritarian Precincts",
      name_singular_possessive: 'Tbilisi Majoritarian Precinct', name_singular_in: 'in Tbilisi Majoritarian Precinct')

  end

  def down
    names = ['Tbilisi Majoritarian District', 'Tbilisi Majoritarian Precinct']
    locale = I18n.locale
    I18n.locale = :en
    ShapeType.with_translations(:en).where(shape_type_translations: {name_singular: names}).destroy_all

    I18n.locale = locale
  end
end
