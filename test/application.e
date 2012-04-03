note
	description : "HAL application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	SHARED_EJSON

create
	make

feature {NONE} -- Initialization

	make
		local
--			hlink : LINK
--			hresource : RESOURCE
		do
			create file_reader
--			test_json_min
--			test_json_hal
--			test_json_link
			test_hal_loco
		end

	test_hal_loco
		local
			hal: JSON_HAL_RESOURCE_CONVERTER
		do
			create hal.make
			json.add_converter (hal)
			if attached json_file_from ("hal_example.json") as json_file then
				if attached {JSON_OBJECT} json_value_from_file (json_file) as jo then
					if attached {RESOURCE} json.object (jo, "RESOURCE") as r then
						print (r.out)
						if attached json.value (r) as jv then
							 print (jv.representation)
						end
					end
				end
			end
		end

	test_json_hal
    		--
		do
			if attached json_file_from ("hal_example.json") as json_file then
				if attached {JSON_OBJECT} json_value_from_file (json_file) as jo then
					print (jo.representation)
				end
			end
		end

	test_json_link
			--
		local
			r : HASH_TABLE [LINK, STRING]
		do
			if attached json_file_from ("hal_multi_links.json") as json_file then
				if attached {JSON_OBJECT} json_value_from_file (json_file) as jo then
					if attached {JSON_OBJECT} jo.item ("_links") as j_links then
						r := from_json_link (j_links)
						print (r.out)
					end
				end
			end
		end

	test_json_min
    		--
		do
			if attached json_file_from ("min_hal.json") as json_file then
				if attached {JSON_OBJECT} json_value_from_file (json_file) as jo then
					print (jo.representation)
				end
			end
		end

feature -- Implementation	

	file_reader: JSON_FILE_READER

   	json_file_from (fn: STRING): detachable STRING
		do
			Result := file_reader.read_json_from (fn)
		ensure
			Result /= Void
		end

	new_json_parser (a_string: STRING): JSON_PARSER
		do
			create Result.make_parser (a_string)
		end

	json_value_from_file (json_file: STRING): detachable JSON_VALUE
		local
			p: like new_json_parser
		do
			p := new_json_parser (json_file)
			Result := p.parse_json
			check json_is_parsed: p.is_parsed end
		end

feature -- Converter Implementation

	from_json_link (j: JSON_OBJECT): HASH_TABLE [LINK, STRING]
		local
			l_keys: ARRAY [JSON_STRING]
			l_key_i: JSON_STRING
			i,k: INTEGER
			l_link: LINK
		do
			create Result.make(2)
			from
				i := 1
				l_keys := j.current_keys
			until
				i > l_keys.count
			loop
				l_key_i := l_keys[i]
				if attached {JSON_OBJECT} j.item (l_key_i) as jo then
					create l_link.make_with_attribute (l_key_i.item, create_link_attributes (jo))
					Result.force (l_link, l_key_i.item)
				elseif attached {JSON_ARRAY} j.item (l_key_i) as ja then
					create l_link.make (l_key_i.item)
					from
						k := 1
					until
						k > ja.count
					loop
						if attached {JSON_OBJECT} ja.i_th (k) as ji then
							l_link.add_attribute (create_link_attributes (ji))
						end
						k := k + 1
					end
					Result.force (l_link, l_key_i.item)
				end
				i := i +1
			end
		end

	create_link_attributes (j: JSON_OBJECT): LINK_ATTRIBUTE
		do
			if attached {JSON_STRING} j.item ("href") as js1 then
				create Result.make (js1.item)
				if attached {JSON_STRING} j.item ("name") as js2 then
					Result.set_name (js2.item)
				end
				if attached {JSON_STRING} j.item ("title") as js3 then
					Result.set_title (js3.item)
				end
				if attached {JSON_STRING} j.item ("hreflang") as js4 then
					Result.set_hreflang (js4.item)
				end
			end
		end

end
