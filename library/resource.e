note
	description: "Resources have their own state, links, and embedded resources (which are resources in their own right)"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	RESOURCE

create
	make,
	make_with_link
--	make_with_link_resources,
--	make_with_link_resources_properties

feature {NONE} -- Initialization
	make
		do
			create links.make (10)
			links.compare_objects
		end

	make_with_link ( a_link : LINK )
		-- Create a new resource with his self.link
		do
			make
			add_link ("self", a_link)
		end
feature -- Access
	links : HASH_TABLE[LINK,STRING]
	embedded_resource : detachable HASH_TABLE[LIST[RESOURCE],STRING]
	properties : detachable HASH_TABLE[STRING,STRING]


feature -- Element Change
	add_all_link ( all_link : HASH_TABLE[LINK,STRING])
		do
			links.copy (all_link)
		end

	add_link ( a_key: STRING; a_link : LINK)
			-- add an (a_key,a_link) pair
		do
			links.force (a_link, a_key)
		end

	add_properties (key : STRING; value : STRING)
		do
			if attached properties as l_prop then
				l_prop.force (value, key)
			else
				create properties.make (5)
				if attached properties as l_prop then
					l_prop.force (value, key)
				end
			end
		end

	add_embedded (key: STRING; resources: LIST[RESOURCE])
		do
			if attached embedded_resource as er then
				er.force (resources, key)
			else
				create embedded_resource.make (10)
				if attached  embedded_resource as er2 then
					er2.force (resources, key)
				end

			end
		end

	is_valid_resource : BOOLEAN
			-- Does this resource contains a self link?
		do
			Result := links.has_key ("self")
		end

end

