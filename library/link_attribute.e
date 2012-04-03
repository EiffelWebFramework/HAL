note
	description: " Represent LINKs properties, a relation can have multiple links sharing the same key"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LINK_ATTRIBUTE

create
	make

feature {NONE}-- Initialization

	make (a_ref : STRING)
		do
			set_href (a_ref)
		end

feature -- Access

	href: STRING
	name : detachable STRING
	title: detachable STRING
	hreflang : detachable STRING

feature -- Element change

	set_href (a_href: STRING)
			-- Set href with `a_href'
		do
			href := a_href
		ensure
			assigned: href ~ a_href
		end

	set_name (a_name: STRING)
			-- Set name with `a_name'
		do
			name := a_name
		ensure
			assigned: name ~ a_name
		end

	set_title (a_title: STRING)
			-- Set title with `a_title'
		do
			title := a_title
		ensure
			assigned: title ~ a_title
		end

	set_hreflang (a_hreflang: STRING)
			-- Set hreflang with `a_hreflang'
		do
			hreflang := a_hreflang
		ensure
			assigned: hreflang ~ a_hreflang
		end

end
