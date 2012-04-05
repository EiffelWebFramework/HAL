note
	description: "[
			JSON_HAL_RESOURCE_CONVERTER  allow to go `from_json' and return a RESOURCE object and `to_json' convert an object RESOURCE into a JSON 
			representation
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_HAL_RESOURCE_CONVERTER

inherit
	JSON_CONVERTER

create
	make

feature -- Initialization

	make
		do
			create object.make
		end

feature	 -- Access

	object: HAL_RESOURCE
	value: detachable JSON_OBJECT

	from_json (j: attached like value): detachable like object
            -- Convert from JSON value. Returns Void if unable to convert
       local
       		l_list: LIST [like object]
       		j_array, l_embedded_keys: ARRAY [JSON_STRING]
       		i,k,l: INTEGER
        do
        	--| TODO: Refactor to make it simpler
        	create Result.make
            from
            	i := 1
				j_array := j.current_keys
            until
            	i > j_array.count
            loop
            	if not (j_array [i].is_equal (links_key) or  j_array [i].is_equal (embedded_key)) then
					if attached  j.item (j_array [i]) as l_rep then
						Result.add_properties (j_array [i].item, l_rep.representation)
					end
            	end
            	i := i + 1
            end
            if attached {JSON_OBJECT} j.item (links_key) as ll_links then
            	Result.add_all_link (from_json_link (ll_links))
            end
            if attached {JSON_OBJECT} j.item (embedded_key) as ll_embedded then
            	from
            		k := 1
            		l_embedded_keys := ll_embedded.current_keys
            	until
            		k > l_embedded_keys.count
            	loop
            		if attached {JSON_OBJECT} ll_embedded.item (l_embedded_keys [k]) as jo then
						create {ARRAYED_LIST [like object]} l_list.make(1)
						if attached from_json (jo) as jo_r then
							l_list.force (jo_r)
							Result.add_embedded(l_embedded_keys [k].item, l_list)
						end
					elseif attached {JSON_ARRAY} ll_embedded.item (l_embedded_keys [k]) as jea then
                      create {ARRAYED_LIST [like object]} l_list.make (jea.count)
                      from
                      	l := 1
                      until
                      	l > jea.count
                      loop
                      	if attached {JSON_OBJECT} jea.i_th (l) as jeai then
							if attached from_json (jeai) as jeai_r then
								l_list.force (jeai_r)
							end
						end
                        l := l + 1
                      end
                   	  	Result.add_embedded(l_embedded_keys [k].item, l_list)
            		end
            	    k := k + 1
            	end
            end
		 end

    to_json (o: like object): like value
            -- Convert to JSON value
        do
        	create Result.make
            Result.put (to_json_links (o.links), links_key)
			if attached o.embedded_resource as l_embedded_resource then
				Result.put (to_json_embedded_resource (l_embedded_resource),embedded_key)
			end
			if attached o.properties as l_properties then
				from
					l_properties.start
				until
					l_properties.after
				loop
					Result.put (json.value (l_properties.item_for_iteration), l_properties.key_for_iteration)
					l_properties.forth
				end
			end
        end

feature {NONE} -- Converter implementation
	to_json_embedded_resource ( an_embedded_resource : HASH_TABLE [LIST [HAL_RESOURCE], STRING]) : JSON_OBJECT
		do
			create Result.make
			from
				an_embedded_resource.start
			until
				an_embedded_resource.after
			loop
				Result.put (to_json_embedded_resource_internal (an_embedded_resource.item_for_iteration), an_embedded_resource.key_for_iteration)
				an_embedded_resource.forth
			end
		end

	to_json_embedded_resource_internal ( e_resource : LIST [HAL_RESOURCE]) : JSON_VALUE
		local
			l_result_arr : JSON_ARRAY
		do
			if e_resource.count = 1 then
				create {JSON_OBJECT} Result.make
				if attached to_json (e_resource.at (1))as l_res then
					Result := l_res
				end
			else
				create {JSON_ARRAY} l_result_arr.make_array
				from
					e_resource.start
				until
					e_resource.after
				loop
					if attached to_json(e_resource.item_for_iteration) as l_iter then
						l_result_arr.add(l_iter)
					end
					e_resource.forth
				end
				Result := l_result_arr
			end
		end


	to_json_links ( a_links : HASH_TABLE [HAL_LINK, STRING]) : JSON_OBJECT
		do
			create Result.make
			from
				a_links.start
			until
				a_links.after
			loop
				Result.put (to_json_link_internal (a_links.item_for_iteration), a_links.key_for_iteration)
				a_links.forth
			end

		end


	to_json_link_internal (a_link : HAL_LINK) : JSON_VALUE
		local
			l_result_arr : JSON_ARRAY
		do
			if a_link.attributes.count = 1 then
				Result := to_json_link_attribute (a_link.attributes.first)
			else
				create {JSON_ARRAY} l_result_arr.make_array
				from
					a_link.attributes.start
				until
					a_link.attributes.after
				loop
					l_result_arr.add (to_json_link_attribute (a_link.attributes.item_for_iteration))
					a_link.attributes.forth
				end
				Result := l_result_arr
			end
		end

	to_json_link_attribute ( a_link_attribute : HAL_LINK_ATTRIBUTE): JSON_OBJECT
		do
			create Result.make
			Result.put (json.value (a_link_attribute.href), href_key)
			if attached a_link_attribute.name as l_name then
				Result.put (json.value (a_link_attribute.href), name_key)
			end
			if attached a_link_attribute.hreflang as l_hreflang then
				Result.put (json.value (a_link_attribute.hreflang), hreflang_key)
			end
			if attached a_link_attribute.title as l_title then
				Result.put (json.value (a_link_attribute.title), title_key)
			end

		end


	from_json_link (j: attached like value) : HASH_TABLE [HAL_LINK, STRING]
		local
			l_keys : ARRAY [JSON_STRING]
			i,k : INTEGER
			l_link : HAL_LINK
		do
		   create Result.make(2)
		   from
		   	 i := 1
		   	 l_keys := j.current_keys
		   until
		   	 i > l_keys.count
		   loop
		 	 if attached {JSON_OBJECT} j.item (l_keys [i]) as jo then
		 	 	if attached create_link_attributes (jo) as la then
					 	create l_link.make_with_attribute (l_keys [i].item, la)
		 	 			Result.force (l_link, l_keys [i].item)
		 	 	end
		 	 elseif attached {JSON_ARRAY} j.item (l_keys [i]) as ja then
				create l_link.make (l_keys [i].item)
				from
					k := 1
				until
					k > ja.count
				loop
					if  attached {JSON_OBJECT} ja.i_th (k) as ji then
						if attached create_link_attributes (ji) as lai then
							l_link.add_attribute (lai)
						end
					end
					k := k + 1
				end
				Result.force (l_link, l_keys [i].item)
		 	 end
		 	 i := i +1
		   end
          end


	create_link_attributes (j: JSON_OBJECT) : detachable HAL_LINK_ATTRIBUTE
			-- create an object LINK_ATTRIBUTE from a JSON_OBJECT
		do
		    --|TODO refactor to make it simpler
			if attached {JSON_STRING} j.item (href_key) as j_href then
				create Result.make (j_href.item)
				if attached {JSON_STRING} j.item (name_key) as j_name then
					Result.set_name (j_name.item)
				end
				if attached {JSON_STRING} j.item (title_key) as j_title then
					Result.set_title (j_title.item)
				end
				if attached {JSON_STRING} j.item (hreflang_key) as j_hreflang then
					Result.set_hreflang (j_hreflang.item)
				end
			end
		end

feature {NONE} -- Implementation: RESOURCE	

	links_key: JSON_STRING
        once
            create Result.make_json ("_links")
        end

	embedded_key: JSON_STRING
        once
            create Result.make_json ("_embedded")
        end

feature {NONE} -- Implementation: LINK

	href_key: JSON_STRING
        once
            create Result.make_json ("href")
        end

	ref_key : JSON_STRING
	 	once
    		create Result.make_json ("ref")
    	end

feature {NONE} -- Implementation: LINK_ATTRIBUTE

	name_key : JSON_STRING

    	once
    		create Result.make_json ("name")
    	end

    title_key : JSON_STRING

    	once
    		create Result.make_json ("title")
    	end

	hreflang_key : JSON_STRING

    	once
    		create Result.make_json ("hreflang")
    	end

end
