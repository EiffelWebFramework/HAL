note
	description: "Summary description for {JSON_LINE_ITEM_CONVERTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_LINE_ITEM_CONVERTER

inherit
    JSON_CONVERTER

create
    make

feature {NONE} -- Initialization

    make
        local
            ucs: STRING_32
        do
            create ucs.make_from_string ("")
			create object.make ("")
        end

feature -- Access

    object: LINE_ITEM

feature -- Conversion

    from_json (j: like to_json): detachable like object
        local
            ucs: detachable STRING_32
            ll: LINKED_LIST [ITEM]
            b: detachable ITEM
            ja: detachable JSON_ARRAY
            i: INTEGER
        do
            ucs ?= json.object (j.item (name_key), Void)
            check ucs /= Void end
            create Result.make (ucs)
            ja ?= j.item (items_key)
            check ja /= Void end
            from
                i := 1
                create ll.make
            until
                i > ja.count
            loop
                b ?= json.object (ja [i], "ITEM")
                check b /= Void end
                ll.force (b)
                i := i + 1
            end
            check ll /= Void end
            Result.add_items (ll)
        end

    to_json (o: like object): JSON_OBJECT
        do
            create Result.make
			--Result.put (json.value (o.name), name_key)
            Result.put (json.value (o.items), items_key)
        end

feature    {NONE} -- Implementation

    name_key: JSON_STRING
        once
            create Result.make_json ("name")
        end

    items_key: JSON_STRING
        once
            create Result.make_json ("items")
        end

end -- class JSON_LINE_ITEM_CONVERTER
