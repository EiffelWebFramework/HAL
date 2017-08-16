note
	description: "[
		Resources have their own state, links, and embedded resources (which are resources in their own right
		]"
	date: "$Date$"
	revision: "$Revision$"
	specification: "http://stateless.co/hal_specification.html"
	EIS: "JSON HAL Resource specification", "src=https://tools.ietf.org/html/draft-kelly-json-hal-07", "protocol=uri"

class
	HAL_RESOURCE

create
	make,
	make_with_link

feature {NONE} -- Initialization

	make
			-- Create a default HAL resource
		do
			create links.make (10)
			links.compare_objects
		end

	make_with_link (a_link: HAL_LINK)
			-- Create a new resource with his self.link `a_link'
		do
			make
			add_link_with_key ("self", a_link)
		end

feature -- Access

	self: detachable HAL_LINK
			-- Return the self link
			-- For example if you have the following JSON representation
			--
			--		"_links": {
			--		    "self": { "href": "/orders" },
			--		    "next": { "href": "/orders?page=2" },
			--		    "search": { "href": "/orders?id={order_id}" }
			--		  }

			--	you will get an object equivalent to the following JSON fragment

			-- 			"self": { "href": "/orders" },
			--
		require
			valid: is_valid_resource
		do
			Result := links.at ("self")
		ensure
			valid: Result /= Void
		end

	curies: detachable HAL_LINK
			-- Return the curies link
			-- For example if you have the following JSON representation
			--
			--	{
			--  	"_links": {
			--   	 	"self": { "href": "orders" },
			-- 		   "curies" : [
			--    			  { "name": "api-root", "href": "https://api.example.org/{?href}", "templated": true},
			--     			  { "name": "file-api-root", "href": "https://pool-2.static.example.org/file/{?href}", "templated": true }
			--    			]
			--  	},

			--	you will get an object equivalent to the following JSON fragment

			--			 "curies" : [
			--    			  { "name": "api-root", "href": "https://api.example.org/{?href}", "templated": true},
			--     			  { "name": "file-api-root", "href": "https://pool-2.static.example.org/file/{?href}", "templated": true }
			--    			]		
		require
			valid: is_valid_resource
		do
			Result := links.at ("curies")
		end


	links_keys: ARRAY [READABLE_STRING_GENERAL]
			-- Return an array of keys, ie rel attributes
			-- For example if you have the following JSON representation
			--
			--		"_links": {
			--		    "self": { "href": "/orders" },
			--		    "next": { "href": "/orders?page=2" },
			--		    "search": { "href": "/orders?id={order_id}" }
			--		  }

			-- you will get an ARRAY witht he following keys

			-- 			"self","next","search"
			--
		do
			Result := links.current_keys
		end

	links_by_key (a_key: READABLE_STRING_GENERAL): detachable HAL_LINK
			-- Retrieve a link given a `a_key', ie a rel attribute if it exist,
			-- Void in othercase
			-- For example if you have the following JSON representation
			--
			--		"_links": {
			--		    "self": { "href": "/orders" },
			--		    "next": { "href": "/orders?page=2" },
			--		    "search": { "href": "/orders?id={order_id}" }
			--		  }

			-- you will get a LINK if a_key is one of the following values

			-- 			"self","next","search"
			-- Void in other case
		do
			Result := links.at (a_key)
		end

	embedded_resources_keys: detachable ARRAY [READABLE_STRING_GENERAL]
			-- Retrieve an arrray of resource keys, if exist,
			-- Void in othercase
		do
			if attached embedded_resource as er then
				Result := er.current_keys
			end
		end

	embedded_resources_by_key (a_key: READABLE_STRING_GENERAL): detachable LIST [HAL_RESOURCE]
			-- Return a list embedded resources if it exist or Void in other case
		do
			if attached embedded_resource as er then
				Result := er [a_key]
			end
		end

	fields_keys: detachable ARRAY [READABLE_STRING_GENERAL]
			-- Return an array of fields keys if exist,
			-- Void in othercase
		do
			if attached fields as p then
				Result := p.current_keys
			end
		end

	field_by_key (a_key: READABLE_STRING_GENERAL): detachable ANY
			-- Return a value, if key `a_key' exists
			-- Void in othercase
		do
			if attached fields as l_fields then
				Result := l_fields [a_key]
			end
		end

	field_integer_by_key (a_key: READABLE_STRING_GENERAL): INTEGER_64
			-- Return a value, if key `a_key' exists and is integer.
		require
			is_field_integer: field_is_integer (a_key)
		do
			if
				attached fields as l_fields and then
				attached {INTEGER_64} l_fields [a_key] as l_value
			then
				Result := l_value
			end
		end

	field_real_by_key (a_key: READABLE_STRING_GENERAL): REAL_64
			-- Return a value, if key `a_key' exists and is real.
		require
			is_field_integer: field_is_real (a_key)
		do
			if
				attached fields as l_fields and then
				attached {REAL_64} l_fields [a_key] as l_value
			then
				Result := l_value
			end
		end

	field_natural_by_key (a_key: READABLE_STRING_GENERAL): NATURAL_64
			-- Return a value, if key `a_key' exists and is natural.
		require
			is_field_integer: field_is_natural (a_key)
		do
			if
				attached fields as l_fields and then
				attached {NATURAL_64} l_fields [a_key] as l_value
			then
				Result := l_value
			end
		end

	field_boolean_by_key (a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- Return a value, if key `a_key' exists and is boolean.
		require
			is_field_integer: field_is_boolean (a_key)
		do
			if
				attached fields as l_fields and then
				attached {BOOLEAN} l_fields [a_key] as l_value
			then
				Result := l_value
			end
		end

	field_string_by_key (a_key: READABLE_STRING_GENERAL): detachable STRING_32
			-- Return a value, if key `a_key' exists and is string.
		require
			is_field_integer: field_is_string (a_key)
		do
			if
				attached fields as l_fields and then
				attached {READABLE_STRING_32} l_fields [a_key] as l_value
			then
				Result := l_value
			end
		end

	field_object_by_key (a_key: READABLE_STRING_GENERAL): detachable STRING_TABLE [ANY]
			-- Return a value, if key `a_key' exists and is an object reference.
		require
			is_field_integer: field_is_object (a_key)
		do
			if
				attached fields as l_fields and then
				attached {STRING_TABLE [ANY]} l_fields [a_key] as l_value
			then
				Result := l_value
			end
		end

	field_array_by_key (a_key: READABLE_STRING_GENERAL): detachable ARRAY [ANY]
			-- Return a value, if key `a_key' exists and is an array reference.
		require
			is_field_integer: field_is_array (a_key)
		do
			if
				attached fields as l_fields and then
				attached {ARRAY [ANY]} l_fields [a_key] as l_value
			then
				Result := l_value
			end
		end

feature -- Status Report

	field_is_integer (a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- is the field `a_key' integer?
		do
			if
				attached fields as l_fields and then
				attached {INTEGER_64} l_fields [a_key]
			then
				Result := True
			end
		end

	field_is_real (a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- is the field `a_key' real?
		do
			if
				attached fields as l_fields and then
				attached {REAL_64} l_fields [a_key]
			then
				Result := True
			end
		end

	field_is_natural (a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- is the field `a_key' natural?
		do
			if
				attached fields as l_fields and then
				attached {NATURAL_64} l_fields [a_key]
			then
				Result := True
			end
		end

	field_is_boolean (a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- is the field `a_key' boolean?
		do
			if
				attached fields as l_fields and then
				attached {BOOLEAN} l_fields [a_key]
			then
				Result := True
			end
		end

	field_is_string (a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- is the field `a_key' string?
		do
			if
				attached fields as l_fields and then
				attached {READABLE_STRING_32} l_fields [a_key]
			then
				Result := True
			end
		end

	field_is_object (a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- is the field `a_key' string_table?
		do
			if
				attached fields as l_fields and then
				attached {STRING_TABLE [ANY]} l_fields [a_key]
			then
				Result := True
			end
		end

	field_is_array (a_key: READABLE_STRING_GENERAL): BOOLEAN
			-- is the field `a_key' array?
		do
			if
				attached fields as l_fields and then
				attached {ARRAY [ANY]} l_fields [a_key]
			then
				Result := True
			end
		end

feature -- Element Change

	add_all_links (all_link: STRING_TABLE [HAL_LINK])
		do
			across
				all_link as ic
			loop
				add_link_with_key (ic.key, ic.item)
			end
		end

	add_link_with_key (a_key: READABLE_STRING_GENERAL; a_link: HAL_LINK)
			-- add an (a_key,a_link) pair
			-- require a_key is_equal a_link.rel
		local
			l_links: like links
		do
			l_links := links
			if l_links = Void then
				create l_links.make (10)
				l_links.compare_objects
				links := l_links
			elseif
				l_links.has (a_link.rel) and then
				attached {HAL_LINK} l_links [a_link.rel] as l_hal
			then
				l_hal.attributes.append (a_link.attributes)
				l_links := Void
			end
			if l_links /= Void then
				l_links.force (a_link, a_key)
			end
		end

	add_link (a_link: HAL_LINK)
		do
			add_link_with_key (a_link.rel, a_link)
		end

	add_curie_link (a_attribute: HAL_LINK_ATTRIBUTE)
		do
			add_link_with_key ("curies", create {HAL_LINK}.make_with_attribute ("curies", a_attribute))
		end

	add_fields (key: READABLE_STRING_GENERAL; value: ANY)
		obsolete
			"Use `add_field` [2017-06-20]"
		do
			add_field (key, value)
		end

	add_field (key: READABLE_STRING_GENERAL; value: ANY)
		obsolete
				"[
					Use `dd_string_field, add_integer_field, add_real_field, add_natural_field, add_boolean_field, add_null_field [2017-06-20]
					]"
		local
			l_fields: like fields
		do
			l_fields := fields
			if l_fields = Void then
				create l_fields.make (1)
				fields := l_fields
			end
			l_fields.force (value, key)
		end

	add_string_field (key: READABLE_STRING_GENERAL; value: READABLE_STRING_32)
		local
			l_fields: like fields
		do
			l_fields := fields
			if l_fields = Void then
				create l_fields.make (1)
				fields := l_fields
			end
			l_fields.force (value, key)
		end

	add_integer_field (key: READABLE_STRING_GENERAL; value: INTEGER_64)
		local
			l_fields: like fields
		do
			l_fields := fields
			if l_fields = Void then
				create l_fields.make (1)
				fields := l_fields
			end
			l_fields.force (value, key)
		end

	add_real_field (key: READABLE_STRING_GENERAL; value: REAL_64)
		local
			l_fields: like fields
		do
			l_fields := fields
			if l_fields = Void then
				create l_fields.make (1)
				fields := l_fields
			end
			l_fields.force (value, key)
		end

	add_natural_field (key: READABLE_STRING_GENERAL; value: NATURAL_64)
		local
			l_fields: like fields
		do
			l_fields := fields
			if l_fields = Void then
				create l_fields.make (1)
				fields := l_fields
			end
			l_fields.force (value, key)
		end

	add_boolean_field (key: READABLE_STRING_GENERAL; value: BOOLEAN)
		local
			l_fields: like fields
		do
			l_fields := fields
			if l_fields = Void then
				create l_fields.make (1)
				fields := l_fields
			end
			l_fields.force (value, key)
		end

	add_null_field (key: READABLE_STRING_GENERAL)
		local
			l_fields: like fields
		do
			l_fields := fields
			if l_fields = Void then
				create l_fields.make (1)
				fields := l_fields
			end
			l_fields.force ("null", key)
		end

	add_array_field (key: READABLE_STRING_GENERAL; a_array: ARRAY [ANY])
		local
			l_fields: like fields
		do
			l_fields := fields
			if l_fields = Void then
				create l_fields.make (1)
				fields := l_fields
			end
			l_fields.force (a_array, key)
		end

	add_object_field (key: READABLE_STRING_GENERAL; a_object: STRING_TABLE [ANY])
		local
			l_fields: like fields
		do
			l_fields := fields
			if l_fields = Void then
				create l_fields.make (1)
				fields := l_fields
			end
			l_fields.force (a_object, key)
		end

	add_embedded_resource_with_key (key: READABLE_STRING_GENERAL; res: HAL_RESOURCE)
		local
			er: like embedded_resource
		do
			er := embedded_resource
			if er = Void then
				create er.make (10)
				embedded_resource := er
				er.compare_objects
			end
			if er.has (key) and then attached {LIST [HAL_RESOURCE]} er.at (key) as l_er then
				l_er.force (res)
			end
		end

	add_embedded_resources_with_key (key: READABLE_STRING_GENERAL; resources: LIST [HAL_RESOURCE])
		local
			er: like embedded_resource
		do
			er := embedded_resource
			if er = Void then
				create er.make (10)
				embedded_resource := er
				er.compare_objects
			end
			er.force (resources, key)
		end

feature -- Status Report

	is_valid_resource: BOOLEAN
			-- Does this resource contains a self link?
			-- or is an empty json {}?
		do
			Result := links.has_key ("self") or else links.is_empty
		end


feature {HAL_ACCESS} -- Implementation

	links: STRING_TABLE [HAL_LINK]
			--  contains links to other resources.

	embedded_resource: detachable STRING_TABLE [LIST [HAL_RESOURCE]]
			-- expressing the embedded nature of a given part of the representation.

	fields: detachable STRING_TABLE [ANY]
			-- Properties representing current state of Current resource.


end
