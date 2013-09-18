# encoding: UTF-8
class ChangeIndicatorNames < ActiveRecord::Migration
  def up
    CoreIndicatorTranslation.transaction do
      ind_name = 'Average age of voters'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'Average age of registered voters'
        ind.first.description = 'Average age of registered voters'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)

      ind_name = 'ამომრჩეველთა საშუალო ასაკი'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'დარეგისტრირებულ ამომრჩეველთა საშუალო ასაკი'
        ind.first.description = 'დარეგისტრირებულ ამომრჩეველთა საშუალო ასაკი'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)

      ind_name = 'Total Turnout (#)'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'Total Voter Turnout (#)'
        ind.first.description = 'Total Voter Turnout (#)'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)

      ind_name = 'Total Turnout (%)'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'Total Voter Turnout (%)'
        ind.first.description = 'Total Voter Turnout (%)'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)

      ind_name = 'აქტივობა (#)'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'ამომრჩეველთა აქტივობა (#)'
        ind.first.description = 'ამომრჩეველთა აქტივობა (#)'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)

      ind_name = 'აქტივობა (%)'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'ამომრჩეველთა აქტივობა (%)'
        ind.first.description = 'ამომრჩეველთა აქტივობა (%)'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)
    end
  end

  def down
    CoreIndicatorTranslation.transaction do
      ind_name = 'Average age of registered voters'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'Average age of voters'
        ind.first.description = 'Average age of voters'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)

      ind_name = 'დარეგისტრირებულ ამომრჩეველთა საშუალო ასაკი'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'ამომრჩეველთა საშუალო ასაკი'
        ind.first.description = 'ამომრჩეველთა საშუალო ასაკი'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)

      ind_name = 'Total Voter Turnout (#)'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'Total Turnout (#)'
        ind.first.description = 'Total Turnout (#)'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)

      ind_name = 'Total Voter Turnout (%)'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'Total Turnout (%)'
        ind.first.description = 'Total Turnout (%)'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)

      ind_name = 'ამომრჩეველთა აქტივობა (#)'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'აქტივობა (#)'
        ind.first.description = 'აქტივობა (#)'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)

      ind_name = 'ამომრჩეველთა აქტივობა (%)'
      ind = CoreIndicatorTranslation.where(:name => ind_name)
      if ind.present?
        ind.first.name = 'აქტივობა (%)'
        ind.first.description = 'აქტივობა (%)'
        ind.first.save
      end
      CoreIndicatorSweeper.instance.after_update(ind.first.core_indicator)
    end
  end
end
