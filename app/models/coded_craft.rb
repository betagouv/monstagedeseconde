class CodedCraft < ApplicationRecord
  include PgSearch::Model
  
  belongs_to :detailed_craft
  has_many :coded_craft_fields, dependent: :destroy, inverse_of: :coded_craft

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :ogr_code, presence: true, length: { maximum: 10 }, uniqueness: true

  pg_search_scope :search_by_keyword,
                  against: :name,
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      dictionary: 'public.config_search_keyword',
                      tsvector_column: 'name_tsv',
                      prefix: true
                    }
                  }

end
