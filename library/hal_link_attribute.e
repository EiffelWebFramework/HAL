note
	description: " Represent LINKs properties, a relation can have multiple links sharing the same key"
	author: ""
	date: "$Date$"
	revision: "$Revision$"
	specification:"http://stateless.co/hal_specification.html"

class
	HAL_LINK_ATTRIBUTE

create
	make

feature {NONE}-- Initialization

	make (a_ref : STRING)
		do
			set_href (a_ref)
		end

feature -- Access

	href: STRING
		--@href
		--REQUIRED
		--For indicating the target URI.
		--@href corresponds with the 'Target IRI' as defined in Web Linking [RFC 5988]		

	name : detachable STRING
		--@name
		--OPTIONAL
		--For distinguishing between Resource and Link elements that share the same @rel value.
		--The @name attribute SHOULD NOT be used exclusively for identifying elements within a HAL representation,
		--it is intended only as a 'secondary key' to a given @rel value.	

	title: detachable STRING
		--@title
		--OPTIONAL
		--For labeling the destination of a link with a human-readable identifier.

	hreflang : detachable STRING
		--@hreflang
		--OPTIONAL
		--For indicating what the language of the result of dereferencing the link should be.

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
