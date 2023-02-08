def custom_fields 
  [
    {
      "field_type" => "TextField",
      "field_name" => "Manufacturer",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers, canopies, aads, jumpsuits, helmets, cameras, altimeters, flying-accessories, rigging-and-packing, jewelry, collectibles",
      "choices" => "Select an option, ...",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "TextField",
      "field_name" => "Model",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers, canopies, aads, jumpsuits, helmets, cameras, altimeters, flying-accessories, rigging-and-packing, jewelry, collectibles",
      "choices" => "Select an option, ...",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "TextField",
      "field_name" => "Container Size",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers",
      "choices" => "Select an option, ...",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Height Range (optional)",
      "required?" => "0",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers",
      "choices" => "less than 5' / less than 152cm, 5'-5'2\" / 152cm-157cm, 5'2\"-'5\"4\" / 157cm-163cm, 5'4\"-5'6\" / 163cm-168cm, 5'6\"-5'8\" / 168cm-173cm, 5'8\"-5'10\" / 173cm-178cm, 5'10\"-6'0\" / 178cm-183cm, 6'0\"-6'2\" / 183cm-188cm, 6'2\"-6'4\" / 188cm-193cm, 6'4\"-6'6\" / 193cm-198cm, more than 6'6\" / more than 198cm",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Weight Range (optional)",
      "required?" => "0",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers",
      "choices" => "less than 90lbs / less than 41kg, 90lbs-100lbs / 41kgs-45kgs, 100lbs-110lbs / 45kgs-50kgs, 110lbs-120lbs / 50kgs-55kgs, 120lbs-130lbs / 55kgs-59kgs, 130lbs-140lbs / 59kgs-64kgs, 140lbs-150lbs / 64kgs-68kgs, 150lbs-160lbs / 68kgs-73kgs, 160lbs-170lbs / 73kgs-77kgs, 170lbs-180lbs / 77kgs-82kgs, 180lbs-190lbs / 82kgs-86kgs, 190lbs-200lbs / 86kgs-91kgs, 200lbs-210lbs / 91kgs-95kgs, 210lbs-220lbs / 95kgs-100kgs, 220lbs-230lbs / 100kgs-105kgs, 230lbs-240lbs / 105kgs-109kgs, 240lbs-250lbs / 109kgs-114kgs, more than 250lbs / more than 114kbs",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "TextField",
      "field_name" => "Size",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "canopies, jumpsuits, helmets, altimeter-watches, flying-accessories, rigging-and-packing, jewelry",
      "choices" => "Select an option, ...",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "TextField",
      "field_name" => "Size (optional)",
      "required?" => "0",
      "search_filter?" => "",
      "categories_it_applies_to" => "collectibles",
      "choices" => "",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Color",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers, canopies, jumpsuits, helmets, flying-accessories, rigging-and-packing, jewelry, collectibles",
      "choices" => "Black, Blue, Brown, Camo, Gold, Green, Grey, Orange, Pink, Purple, Red, Silver, White, Yellow, Rainbow",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Secondary Color (optional)",
      "required?" => "0",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers, canopies, jumpsuits, helmets, flying-accessories, rigging-and-packing, jewelry, collectibles",
      "choices" => "Black, Blue, Brown, Camo, Gold, Green, Grey, Orange, Pink, Purple, Red, Silver, White, Yellow, Rainbow",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Condition",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers, canopies, aads, jumpsuits, helmets, cameras, altimeters, flying-accessories, rigging-and-packing, jewelry, collectibles",
      "choices" => "New, Like New, Good, Just For Parts",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DateField",
      "field_name" => "DOM",
      "required?" => "0",
      "search_filter?" => "",
      "categories_it_applies_to" => "containers, canopies, aads",
      "choices" => "",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Jump Number",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers, main, tandem, powered, speedflying, b.a.s.e., jumpsuits",
      "choices" => "0, 1-50, 51-100, 101-250, 251-500, 501-1000, 1001-3000, 3001-5000, 5000+",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Ride Number",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "reserve",
      "choices" => "0,1,2,3,4,5,6,7,8,9,10,10+",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Repack Number",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "reserve",
      "choices" => "0,1,2,3,4,5,6,7,8,9,10,10+",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "AAD ready?",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers",
      "choices" => "yes, no",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "RSL?",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers",
      "choices" => "yes, skyhook, no RSL",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Lines",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "main, tandem, powered, speedflying, b.a.s.e.",
      "choices" => "Vectran, HMA, Microline, Dacron",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Lineset Jump Number",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "main, tandem, powered, speedflying, b.a.s.e.",
      "choices" => "0, 1-50, 51-100, 101-200, 201-300, 301-500, 501-1000, 1000+",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Patches? (optional)",
      "required?" => "0",
      "search_filter?" => "1",
      "categories_it_applies_to" => "canopies",
      "choices" => "yes, no",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Fired?",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "aads",
      "choices" => "yes, no",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DateField",
      "field_name" => "Last Service Date",
      "required?" => "1",
      "search_filter?" => "",
      "categories_it_applies_to" => "aads",
      "choices" => "",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "DropdownField",
      "field_name" => "Original Owner?",
      "required?" => "1",
      "search_filter?" => "1",
      "categories_it_applies_to" => "containers, canopies, aads, jumpsuits, helmets, cameras, altimeters, flying-accessories, rigging-and-packing, jewelry, collectibles",
      "choices" => "yes, no",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    },
    {
      "field_type" => "TextField",
      "field_name" => "Serial #",
      "required?" => "0",
      "search_filter?" => "",
      "categories_it_applies_to" => "containers, canopies, aads",
      "choices" => "",
      "min" => "",
      "max" => "",
      "allow_decimals" => ""
    }
  ]
end