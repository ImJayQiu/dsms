class AddAttachmentFileToDatasets < ActiveRecord::Migration
  def self.up
    change_table :datasets do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :datasets, :file
  end
end
