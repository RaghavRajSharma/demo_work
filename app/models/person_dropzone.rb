# == Schema Information
#
# Table name: person_dropzones
#
#  id          :integer          not null, primary key
#  dropzone_id :integer
#  person_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PersonDropzone < ApplicationRecord
  belongs_to :person
  belongs_to :dropzone, :class_name => "DropZone"
end
