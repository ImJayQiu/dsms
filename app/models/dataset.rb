class Dataset < ActiveRecord::Base

	has_attached_file :file,
		url: "/datasets/:id/:basename.:extension",
		path: ":rails_root/public/datasets/:id/:basename.:extension"


	validates_attachment :file, presence: true,
		content_type: { content_type: "application/x-netcdf" },
			size: { in: 1..1000000.megabytes }
end
