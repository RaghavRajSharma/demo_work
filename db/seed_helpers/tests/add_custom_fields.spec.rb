require 'rspec'
require_relative '../add_custom_fields'

describe "merge_params(config)" do 
  describe "creates a params hash to replicate form submission" do 
    context "Dropdown Field" do 
        
      it "adds correct values to params" do 
        config = {
          "field_name"=>"Condition", 
          "field_type"=>"DropdownField", 
          "required?"=>"1", 
          "search_filter?"=>"1", 
          "categories_it_applies_to"=>"all",
          "choices"=>"New, Like New, Good, Just For Parts"
        }
        expect(merge_params(config)[:custom_field][:name_attributes][:en]).to eq("Condition")
        expect(merge_params(config)[:field_type]).to eq("DropdownField")
        expect(merge_params(config)[:custom_field][:required]).to eq("1")
        expect(merge_params(config)[:custom_field][:search_filter]).to eq("1")
        expect(merge_params(config)[:custom_field][:category_attributes].size).to eq(76)
        expect(merge_params(config)[:custom_field][:option_attributes]).not_to eq(nil)
        
      end

      it "adds categories by name" do 
        config = {
          "field_name"=>"Lines (Type)", 
          "field_type"=>"DropdownField", 
          "required?"=>"1", 
          "search_filter?"=>"1", 
          "categories_it_applies_to"=>"Canopies",
          "choices"=>"Dacron, Microline, Vectran, and HMA"
        }
        canopies = Category.find_by_url("canopies")
        output = merge_params(config)
        expect(output[:custom_field][:name_attributes][:en]).to eq("Lines (Type)")
        expect(output[:field_type]).to eq("DropdownField")
        expect(output[:custom_field][:required]).to eq("1")
        expect(output[:custom_field][:search_filter]).to eq("1")
        expect(output[:custom_field][:category_attributes].size).to eq(6)
        canopies.subcategory_ids.each_with_index do |subcategory_id, index| 
          expect(output[:custom_field][:category_attributes][index][:category_id]).to eq(subcategory_id.to_s)
        end
        expect(output[:custom_field][:option_attributes]).not_to eq(nil)
      end

      it "adds multi word categories correctly" do 
        config = {
          "field_name"=>"Lines (Type)", 
          "field_type"=>"DropdownField", 
          "required?"=>"1", 
          "search_filter?"=>"1", 
          "categories_it_applies_to"=>"Rigging & Packing Accessories",
          "choices"=>"Dacron, Microline, Vectran, and HMA"
        }
        rigging_accessories = Category.find_by_url("rigging-and-packing-accessories")
        output = merge_params(config)
        expect(output[:custom_field][:name_attributes][:en]).to eq("Lines (Type)")
        expect(output[:field_type]).to eq("DropdownField")
        expect(output[:custom_field][:required]).to eq("1")
        expect(output[:custom_field][:search_filter]).to eq("1")
        expect(output[:custom_field][:category_attributes].size).to eq(25)
        rigging_accessories.subcategory_ids.each_with_index do |subcategory_id, index| 
          expect(output[:custom_field][:category_attributes][index][:category_id]).to eq(subcategory_id.to_s)
        end
        expect(output[:custom_field][:option_attributes]).not_to eq(nil)
      end

      it "handles adding to a parent category" do 
        config = {
          "field_name"=>"RSL", 
          "field_type"=>"DropdownField", 
          "required?"=>"1", 
          "search_filter?"=>"1", 
          "categories_it_applies_to"=>"Containers",
          "choices"=>"yes, skyhook, no RSL"
        }
        category = Category.find_by_url("containers")
        output = merge_params(config)
        expect(output[:custom_field][:name_attributes][:en]).to eq("RSL")
        expect(output[:field_type]).to eq("DropdownField")
        expect(output[:custom_field][:required]).to eq("1")
        expect(output[:custom_field][:search_filter]).to eq("1")
        expect(output[:custom_field][:category_attributes].size).to eq(1)
        expect(output[:custom_field][:category_attributes][0][:category_id]).to eq(category.id.to_s)
        expect(output[:custom_field][:option_attributes]).not_to eq(nil)
        expect(output[:custom_field][:option_attributes].size).to eq(3)
      end

      it "adds 4 options correctly" do 
        config = {
          "field_name"=>"Condition", 
          "field_type"=>"DropdownField", 
          "required?"=>"1", 
          "search_filter?"=>"1", 
          "categories_it_applies_to"=>"all",
          "choices"=>"New, Like New, Good, Just For Parts"
        }
        option1 = {
          :id=>"new-1", 
          :title_attributes=>{:en=>"New"}, 
          :sort_priority=>"1"
        }
        option2 = {
          :id=>"new-2", 
          :title_attributes=>{:en=>"Like New"}, 
          :sort_priority=>"2"
        }
        option3 = {
          :id=>"jsnew-1", 
          :title_attributes=>{:en=>"Good"}, 
          :sort_priority=>"3"
        }
        option4 = {
          :id=>"jsnew-2", 
          :title_attributes=>{:en=>"Just For Parts"}, 
          :sort_priority=>"4"
        }
        expect(merge_params(config)[:custom_field][:option_attributes]["new-1"]).to eq(option1)
        expect(merge_params(config)[:custom_field][:option_attributes]["new-2"]).to eq(option2)
        expect(merge_params(config)[:custom_field][:option_attributes]["jsnew-1"]).to eq(option3)
        expect(merge_params(config)[:custom_field][:option_attributes]["jsnew-2"]).to eq(option4)
        expect(merge_params(config)[:custom_field][:option_attributes].size).to eq(4)
      end

      it "adds 2 options correctly" do 
        config = {
          "field_name"=>"Condition", 
          "field_type"=>"DropdownField", 
          "required?"=>"1", 
          "search_filter?"=>"1", 
          "categories_it_applies_to"=>"all",
          "choices"=>"New, Like New"
        }
        option1 = {
          :id=>"new-1", 
          :title_attributes=>{:en=>"New"}, 
          :sort_priority=>"1"
        }
        option2 = {
          :id=>"new-2", 
          :title_attributes=>{:en=>"Like New"}, 
          :sort_priority=>"2"
        }
        expect(merge_params(config)[:custom_field][:option_attributes]["new-1"]).to eq(option1)
        expect(merge_params(config)[:custom_field][:option_attributes]["new-2"]).to eq(option2)
        expect(merge_params(config)[:custom_field][:option_attributes].size).to eq(2)
      end

      it "adds 5 options correctly" do 
        config = {
          "field_name"=>"Condition", 
          "field_type"=>"DropdownField", 
          "required?"=>"1", 
          "search_filter?"=>"1", 
          "categories_it_applies_to"=>"all",
          "choices"=>"New, Like New, Good, Fair, Just For Parts"
        }
        option1 = {
          :id=>"new-1", 
          :title_attributes=>{:en=>"New"}, 
          :sort_priority=>"1"
        }
        option2 = {
          :id=>"new-2", 
          :title_attributes=>{:en=>"Like New"}, 
          :sort_priority=>"2"
        }
        option3 = {
          :id=>"jsnew-1", 
          :title_attributes=>{:en=>"Good"}, 
          :sort_priority=>"3"
        }
        option4 = {
          :id=>"jsnew-2", 
          :title_attributes=>{:en=>"Fair"}, 
          :sort_priority=>"4"
        }
        option5 = {
          :id=>"jsnew-3", 
          :title_attributes=>{:en=>"Just For Parts"}, 
          :sort_priority=>"5"
        }
        expect(merge_params(config)[:custom_field][:option_attributes]["new-1"]).to eq(option1)
        expect(merge_params(config)[:custom_field][:option_attributes]["new-2"]).to eq(option2)
        expect(merge_params(config)[:custom_field][:option_attributes]["jsnew-1"]).to eq(option3)
        expect(merge_params(config)[:custom_field][:option_attributes]["jsnew-2"]).to eq(option4)
        expect(merge_params(config)[:custom_field][:option_attributes]["jsnew-3"]).to eq(option5)
        expect(merge_params(config)[:custom_field][:option_attributes].size).to eq(5)
      end
    end
  end
end