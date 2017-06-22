note
	description: "Summary description for {SHARED_ORDER_REPOSITORY}."
	author: ""
	date: "$Date: 2015-09-28 20:08:40 +0200 (lun., 28 sept. 2015) $"
	revision: "$Revision: 97942 $"

deferred class
	SHARED_ORDER_REPOSITORY

feature
	order_repo : ORDER_REPOSITORY
		once
			create Result.make
		end
end
