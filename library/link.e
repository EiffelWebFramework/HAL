note
	description: "[
				Links primarily map link relations to URIs in a key/value fashion.
		Links are keyed by their link relation (rel attribute), an a key could have 
		more than one link, here we model as link and link attributes. For example
		"_links": {
    	 	"self": { "href": "/product/987" },
	    	"upsell": [
      				{ "href": "/product/452", "title": "Flower pot" },
      				{ "href": "/product/832", "title": "Hover donkey" }
    				]
			}
		
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"
	description :"http://blog.stateless.co/post/13296666138/json-linking-with-hal"
class
	LINK

create
	make,
	make_with_attribute,
	make_with_list

feature {NONE} -- Initialization
	make (a_rel : STRING)
		do
			set_rel(a_rel)
			create {ARRAYED_LIST[LINK_ATTRIBUTE]} attributes.make(2)
		end

	make_with_attribute (a_rel : STRING; an_attribute : LINK_ATTRIBUTE)
		do
			set_rel(a_rel)
			create {ARRAYED_LIST[LINK_ATTRIBUTE]} attributes.make(1)
			attributes.force (an_attribute)
		end


	make_with_list (a_rel : STRING; array_attributes : ARRAY[LINK_ATTRIBUTE])
		do
			set_rel(a_rel)
			create {ARRAYED_LIST[LINK_ATTRIBUTE]} attributes.make_from_array(array_attributes)
		end

feature -- Access	
	rel:STRING
	attributes : LIST [LINK_ATTRIBUTE]

feature -- Element change

	set_rel (a_rel:STRING)
			-- Set rel with `a_rel'
		do
			rel := a_rel
		ensure
			assigned: rel ~ a_rel
		end

	add_attribute (an_attribute : LINK_ATTRIBUTE)
		do
			attributes.force (an_attribute)
		end
end
