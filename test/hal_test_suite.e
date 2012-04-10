note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	HAL_TEST_SUITE

inherit
	SHARED_EJSON
			rename default_create as default_create_ejson
		end
	EQA_TEST_SET
		redefine
			on_prepare
		select
			default_create
		end

feature {NONE} -- Events

	on_prepare
			-- <Precursor>
		do
			create file_reader
		end

feature -- Test routines

	test_valid_hal
    		--
		local
			l_res : detachable HAL_RESOURCE
		do
			l_res := json_to_resource ("min_hal.json")
			assert("Not Void", l_res /= Void)
			if attached l_res as l_r then
				assert("Is Valid Resource", l_r.is_valid_resource = True)
			end
		end


	test_self
		local
			l_res : detachable HAL_RESOURCE
		do
			l_res := json_to_resource ("min_hal.json")
			assert("Not Void", l_res /= Void)
			if attached l_res as ll_res then
				if attached{HAL_LINK} ll_res.self as l_link then
					assert ("Rel attribute is self", l_link.rel ~ "self" )
					assert ("Has 1 element", l_link.attributes.count = 1 )
					assert ("Has href",l_link.attributes.at (1).href ~ "http://example.com/")
				end
			end
		end


	test_links_key
		local
			l_res : detachable HAL_RESOURCE
			l_arr : ARRAY[STRING]
		do
			l_res := json_to_resource ("hal_example.json")
			assert("Not Void", l_res /= Void)
			if attached{HAL_RESOURCE} l_res as ll_res then
				l_arr := ll_res.links_keys
				l_arr.compare_objects
				assert ("Has three elements", l_arr.count = 3 )
				assert ("Has element self", l_arr.has ("self") = True)
				assert ("Has element next", l_arr.has ("next") = True)
				assert ("Has element searcg", l_arr.has ("search") = True)
			end
		end


	test_links_by_key
		local
			l_res : detachable HAL_RESOURCE
			l_arr : ARRAY[STRING]
		do
			l_res := json_to_resource ("hal_example.json")
			assert("Not Void", l_res /= Void)
			if attached{HAL_RESOURCE} l_res as ll_res then
				assert ("Expected Void",ll_res.links_by_key ("keynotexist") = Void)
				if attached {HAL_LINK} ll_res.links_by_key ("next") as ll_link then
					assert ("Expected rel : next", ll_link.rel ~ "next")
					assert ("Expected shared links 1", ll_link.attributes.count = 1)
					assert ("Expected Href value", ll_link.attributes.at (1).href ~ "/orders?page=2" )
				end
			end
		end




	test_embedded_resources_key
		local
			l_res : detachable HAL_RESOURCE
		do
			l_res := json_to_resource ("hal_example.json")
			assert("Not Void", l_res /= Void)
			if attached {HAL_RESOURCE} l_res as ll_res then
				if attached {ARRAY[STRING]} ll_res.embedded_resources_keys as ll_arr then
					ll_arr.compare_objects
					assert ("Number of elements 1", ll_arr.count = 1)
					assert ("Has element order",ll_arr.has ("order"))
				end
			end
		end


	test_embedded_resource_by_key
		local
			l_res : detachable HAL_RESOURCE
		do
			l_res := json_to_resource ("hal_example.json")
			assert("Not Void", l_res /= Void)
			if attached {HAL_RESOURCE} l_res as ll_res then
				if attached {LIST[HAL_RESOURCE]} ll_res.embedded_resources_by_key ("order") as l_list then
					l_list.compare_objects
					assert ("Number of elements 2", l_list.count = 2)
				end
			end
		end





feature {NONE} -- Implementation
	json_to_resource (fn : STRING) : detachable HAL_RESOURCE
		local
			parse_json: like new_json_parser
			hal: JSON_HAL_RESOURCE_CONVERTER
		do
			create hal.make
			json.add_converter (hal)
			if attached json_file_from (fn) as json_file then
				parse_json := new_json_parser (json_file)
				if attached parse_json.parse_json as jv then
					if attached {HAL_RESOURCE} json.object (jv, "HAL_RESOURCE") as l_hal then
						Result := l_hal
					end
				end
			end
		end

	json_value: detachable JSON_VALUE

	file_reader: JSON_FILE_READER

   	json_file_from (fn: STRING): detachable STRING
		do
			Result := file_reader.read_json_from (test_dir + fn)
			assert ("File contains json data", Result /= Void)
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

	test_dir: STRING
		local
			i: INTEGER
		do
			Result := (create {EXECUTION_ENVIRONMENT}).current_working_directory
			Result.append_character ((create {OPERATING_ENVIRONMENT}).directory_separator)
				-- The should looks like
				-- ..json\test\autotest\test_suite\EIFGENs\test_suite\Testing\execution\TEST_JSON_SUITE.test_json_fail1\..\..\..\..\..\fail1.json
			from
				i := 5
			until
				i = 0
			loop
				Result.append_character ('.')
				Result.append_character ('.')
				Result.append_character ((create {OPERATING_ENVIRONMENT}).directory_separator)
				i := i - 1
			end
		end

end


