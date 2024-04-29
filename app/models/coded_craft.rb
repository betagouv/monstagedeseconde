class CodedCraft < ApplicationRecord
  belongs_to :detailed_craft
  has_many :coded_craft_fields, dependent: :destroy, inverse_of: :coded_craft

  validates :name,
            :ogr_code,
            presence: true,
            uniqueness: true
  validates :ogr_code,length: { maximum: 10 }
  validates :name, length: { maximum: 255}

  def siblings(level: )
    level_name = name_by_level(level) || ''
    coded_craft_list = siblings_by_craft_level(level).uniq
    [level_name, coded_craft_list]
  end

  private

  def name_by_level(level)
    case level
    when 1
      detailed_craft.name
    when 2
      detailed_craft.craft.name
    when 3
      detailed_craft.craft.craft_field.name
    end
  end

  def siblings_by_craft_level(level)
    case level
    when 0
      [self]
    when 1
      CodedCraft.where(detailed_craft_id: detailed_craft_id )
    when 2
      CodedCraft.joins(detailed_craft: :craft)
                .where(craft: {id: detailed_craft.craft_id})
    when 3
      CodedCraft.joins(detailed_craft: {craft: :craft_field})
                .where(craft_field: {id: detailed_craft.craft.craft_field.id})
    end
  end

  def self.values_all_ogr_codes?
    @extended_list.all? { |code| CodedCraft.exists?(ogr_code: code) }
  end

  def self.fetch_coded_craft(ogr_code)
    find_by(ogr_code: ogr_code)
  end
end
