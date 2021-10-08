class Page < ApplicationRecord
  # has_many :images --> I don't have a pages table

  PAGE_TYPES = ['Home', 'Stellenausschreibung', 'Freie Plätze', 'Kinderladen', 'Wir über uns', 'Tagesablauf', 'Räume', 'Konzept', 'Eingewöhnung', 'Team', 'Eltern', 'Kontakt']
end
