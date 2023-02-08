class ListingTitleService 
  @@naming_conventions = {
    "containers" => {order: [:manufacturer, :model, :container_size], variations: :container_size },
    "main" => {order: [:manufacturer, :model, :size], variations: :size},
    "reserve" => {order: [:manufacturer, :model, :size], variations: :size},
    "tandem" => {order: [:manufacturer, :model, :size], variations: :size},
    "base" => {order: [:manufacturer, :model, :size], variations: :size},
    "speedflying" => {order: [:manufacturer, :model, :size], variations: :size},
    "gliding" => {order: [:manufacturer, :model, :size], variations: :size},
    "powered" => {order: [:manufacturer, :model, :size], variations: :size},
    "aads" => {order: [:manufacturer, :model], variations: :size},
    "belly-flying-rw" => {order: [:manufacturer, :model, :size], variations: :size},
    "freeflying-vrw" => {order: [:manufacturer, :model, :size], variations: :size},
    "wingsuit" => {order: [:manufacturer, :model, :size], variations: :size},
    "tracking" => {order: [:manufacturer, :model, :size], variations: :size},
    "camera-flying" => {order: [:manufacturer, :model, :size], variations: :size},
    "tunnel-flying" => {order: [:manufacturer, :model, :size], variations: :size},
    "other-slash-utility" => {order: [:manufacturer, :model, :size], variations: :size},
    "multi-purpose" => {order: [:manufacturer, :model, :size], variations: :size},
    "tactical-slash-military" => {order: [:manufacturer, :model, :size], variations: :size},
    "skysurfing" => {order: [:manufacturer, :model, :size], variations: :size},
    "open-face-helmets" => {order: [:manufacturer, :model], variations: nil},
    "full-face-helmets" => {order: [:manufacturer, :model], variations: nil},
    "camera-helmets" => {order: [:manufacturer, :model], variations: nil},
    "analog-altimeters" => {order: [:manufacturer, :model], variations: nil},
    "digital-altimeters" => {order: [:manufacturer, :model], variations: nil},
    "audible-altimeters" => {order: [:manufacturer, :model], variations: nil},
    "led-altimeters" => {order: [:manufacturer, :model], variations: nil},
    "led-indicator-altimeters" => {order: [:manufacturer, :model], variations: nil},
    "visual-altimeters" => {order: [:manufacturer, :model], variations: nil},
    "altimeter-watches" => {order: [:manufacturer, :model], variations: nil},
    "altimeter-mounts" => {order: [:manufacturer, :model], variations: nil},
    "misc-altimeter-parts" => {order: [:manufacturer, :model], variations: nil},
    "earbuds" => {order: [:manufacturer, :model], variations: nil},
    "cameras" => {order: [:manufacturer, :model], variations: nil},
    "camera-accessories" => {order: [:manufacturer, :model], variations: nil},
    "camera-mounts" => {order: [:manufacturer, :model], variations: nil},
    "gloves" => {order: [:manufacturer, :model], variations: nil},
    "eyewear" => {order: [:manufacturer, :model], variations: nil},
    "weight-belts" => {order: [:manufacturer, :model], variations: nil},
    "hook-knives" => {order: [:manufacturer, :model], variations: nil},
    "strobe-lights" => {order: [:manufacturer, :model], variations: nil},
    "glo-lites" => {order: [:manufacturer, :model], variations: nil},
    "smoke" => {order: [:manufacturer, :model], variations: nil}
  }
  def initialize(category_id_or_url)
    @category = Category.find_by_url_or_id(category_id_or_url)
  end

  def search_title_options(query)
    query = query.to_s
    query = query.split(' ').count > 1 ? query.split(' ').join('') : query
    convention = @@naming_conventions[@category.url]
    product_ids = Variation.where('value LIKE ?', "%#{ActiveRecord::Base.send(:sanitize_sql_like, query)}%").pluck(:product_id).uniq
    products_matching_size = @category.products.where(id: product_ids)
    if convention 
      if convention[:order].include?(:manufacturer) and convention[:order].include?(:model) and @category.products.find { |p| p.manufacturer.downcase.include?(query.downcase) || p.model.downcase.include?(query.downcase) || query.downcase.include?(p.manufacturer.downcase) || query.downcase.include?(p.model.downcase)}
        @category.products.select do |product|
          product.manufacturer.downcase.include?(query.downcase) || product.model.downcase.include?(query.downcase) || query.downcase.include?(product.manufacturer.downcase) || query.downcase.include?(product.model.downcase)
        end.collect do |product|
          if product.options.present?
            product.options.first.last.collect do |option|
              convention[:order].collect do |attr|
                if convention[:variations] == attr
                  option
                else
                  product.send(attr)
                end
              end.join(' ')
              "#{product.manufacturer} #{product.model} #{option}"
            end
          else
            "#{product.manufacturer} #{product.model}"
          end
        end.flatten
      elsif products_matching_size.length > 0
        Product.where(id: product_ids).collect do |product|
          product.options.first.last.select do |option|
            query.include?(option)
          end.collect do |size|
            convention[:order].collect do |attr|
              if convention[:variations] == attr 
                size
              else 
                product.send(attr)
              end
            end.join(' ')
          end
        end.flatten
      end
    end
  end

  def get_fields_from_title(title)
    results = {
      category: @category.url,
      manufacturer: "Other",
      model: "Other", 
      size: "Other"
    }
    
    p = @category.products.find do |product|
      if title.include?(product.manufacturer)
        results[:manufacturer] = product.manufacturer 
        if title.include?(product.model)
          results[:model] = product.model
          if product.options.present?
            if size = product.options.first.last.find {|s| title.include?(s)}
              results[:size] = size
            end
          end
        end
      end 
    end
    @category.custom_fields.present? ? results : {}
  end
end