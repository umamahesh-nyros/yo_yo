class ValidatingBase
  include Reloadable
  def save; end
  def save!; end
  def update_attribute; end
  def new_record?; end
  def self.human_attribute_name(arg)
    arg.to_s
  end
  include ActiveRecord::Validations
  def [](key)
    instance_variable_get(key)
  end
  def initialize(attributes = nil)
    return nil if attributes.nil?

    attributes.each do |key, value|    
      method("#{key}=").call(value)
    end
  end
end
