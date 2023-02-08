module DropzoneHelper
  def dropzone_list 
    DropZone.all.map do |dz|
      [dz.name_and_location, dz.id]
    end
  end
end
