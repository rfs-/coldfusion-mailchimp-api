<!--- 
**************************************************************************************************************
* FILE: Coldfusion Mailchimp API v3
* AUTHOR: Dave Hunter
* VERSION: v1.0.0
* LAST UPDATED: June 16, 2016
* DOCUMENTATION: http://developer.mailchimp.com/documentation/mailchimp/reference/overview/
*************************************************************************************************************/
--->
<cfcomponent displayname="MailChimp" hint="I use the Mail Chimp API v3">

 	<!--- OPTIONS/DEFAULTS --->
	<cffunction name="init" access="public" returntype="Any">
    <cfscript>
			this.options = StructNew();
			this.options.apikey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-usX"; /* enter your api key here */
			this.options.list_id = "xxxxxxxxxx"; /* enter your list id here */
			this.options.template_id = "xxxxxx"; /* enter your template id here */
			this.options.sections = "body_content"; /* default edit region in template */
			this.options.type = "regular"; /* regular or plaintext */
			this.options.twitter = false; /* auto tweet campaigns if true */
			this.options.facebook = ""; /* comma separated list of facebook page ID's */
			this.options.serviceURL = "https://#ListLast(this.options.apikey,"-")#.api.mailchimp.com/3.0/"; /* DO NOT TOUCH */
		</cfscript>
		<cfreturn this />
	</cffunction>
  
  <!---************************************************
	* HELPERS 
	*************************************************--->
  
  <!--- API CALL --->
	<cffunction name="apiCall" access="private" description="This makes a request to the Mailchimp API v3" returnformat="JSON" output="false" returntype="Any">
  	<cfargument name="apiMethod" required="yes" type="string">
    <cfargument name="httpMethod" required="yes" type="string">
    <cfargument name="requestBody" required="no" type="struct">
    <cftry>
			<cfif isDefined('arguments.requestBody')>
				<cfset #arguments.requestBody# = serializejson(arguments.requestBody)>
        <cfhttp url="#this.options.serviceURL##arguments.apiMethod#" method="#arguments.httpMethod#" username="apikey" password="#this.options.apikey#" result="success" timeout="10">
          <cfhttpparam name="Content-Type" value="application/json" type="header" />
          <cfhttpparam name="body" value='#arguments.requestBody#' type="body">
        </cfhttp>
      <cfelse>
      	<cfhttp url="#this.options.serviceURL##arguments.apiMethod#" method="#arguments.httpMethod#" username="apikey" password="#this.options.apikey#" result="success" timeout="10">
          <cfhttpparam name="Content-Type" value="application/json" type="header" />
        </cfhttp>
      </cfif>
      <cfcatch type="Any">
      	<cfset returnStruct = {}>
				<cfset returnStruct['Status'] = 'Error with mailchimp API call'>
        <cfset returnStruct['Error'] = #cfcatch#>
        <cfset returnStruct['Referrer'] = #cgi#>
        <cfreturn returnStruct>
      </cfcatch>
    </cftry>
    <cfif isDefined('success.filecontent') AND #success.filecontent# NEQ ''>
    	<cfset returnStruct = deserializejson(success.filecontent)>
    <cfelse>
    	<cfset returnStruct = #success#>
    </cfif>
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- GET MD5 HASH FOR AN EMAIL ADDRESS --->
  <cffunction name="getMD5Hash" access="private" description="This converts an email address to a MD5 hash" output="false" returntype="Any">
  	<cfargument name="email_address" required="yes" type="string">
  	<cfset #subscriber_hash# = LCase(Hash(LCase(arguments.email_address),'md5'))>
    <cfreturn subscriber_hash>
  </cffunction>
  
  <!--- GET VERIFIED DOMAINS (Currently not available in API v3) --->
  <cffunction name="getVerifiedDomains" access="public" returntype="any" hint="I get verified domains for campaigns">
	 	<cfhttp url="https://#ListLast(this.options.apikey,"-")#.api.mailchimp.com/2.0/helper/verified-domains.json" method="post" timeout="10">
			<cfhttpparam name="apikey" value="#this.options.apikey#" type="url">
		</cfhttp>
    <cfreturn DeserializeJSON(cfhttp.filecontent)>
	</cffunction>
  
  <!---************************************************
	* LISTS 
	* http://developer.mailchimp.com/documentation/mailchimp/reference/lists/
	*************************************************--->
  
  <!--- CREATE LIST --->
	<cffunction name="listCreate" access="public" returntype="any" hint="I create a list">
		<cfargument name="name" required="yes" type="string">
    <cfargument name="company" required="yes" type="string">
    <cfargument name="address1" required="yes" type="string">
    <cfargument name="address2" required="no" type="string">
    <cfargument name="city" required="yes" type="string">
    <cfargument name="state" required="yes" type="string">
    <cfargument name="zip" required="yes" type="string">
    <cfargument name="country" required="yes" type="string">
    <cfargument name="phone" required="no" type="string">
    <cfargument name="permission_reminder" required="yes" type="string" default="You signed up for this list on our website">
		<cfargument name="use_archive_bar" required="no" type="boolean">
    <cfargument name="from_name" required="yes" type="string">
    <cfargument name="from_email" required="yes" type="string">
    <cfargument name="subject" required="yes" type="string">
    <cfargument name="language" required="yes" type="string">
    <cfargument name="notify_on_subscribe" required="no" type="string">
    <cfargument name="notify_on_unsubscribe" required="no" type="string">
    <cfargument name="email_type_option" required="yes" type="boolean">
    <cfargument name="visibility" required="no" type="string" default="pub">
		<cfset requestBody = {}>
    <cfset requestBody['name'] = #arguments.name#>
    <cfset requestBody['contact'] = {}>
    <cfset requestBody.contact['company'] = #arguments.company#>
    <cfset requestBody.contact['address1'] = #arguments.address1#>
    <cfif isDefined('arguments.address2')><cfset requestBody.contact['address2'] = #arguments.address2#></cfif>
		<cfset requestBody.contact['city'] = #arguments.city#>
    <cfset requestBody.contact['state'] = #arguments.state#>
    <cfset requestBody.contact['zip'] = #arguments.zip#>
    <cfset requestBody.contact['country'] = #arguments.country#>
    <cfif isDefined('arguments.phone')><cfset requestBody.contact['phone'] = #arguments.phone#></cfif>
		<cfset requestBody['permission_reminder'] = #arguments.permission_reminder#>
    <cfif isDefined('arguments.use_archive_bar')><cfset requestBody.contact['use_archive_bar'] = #arguments.use_archive_bar#></cfif>
    <cfset requestBody['campaign_defaults'] = {}>
    <cfset requestBody.campaign_defaults['from_name'] = #arguments.from_name#>
    <cfset requestBody.campaign_defaults['from_email'] = #arguments.from_email#>
    <cfset requestBody.campaign_defaults['subject'] = #arguments.subject#>
    <cfset requestBody.campaign_defaults['language'] = #arguments.language#>
    <cfif isDefined('arguments.notify_on_subscribe')><cfset requestBody.contact['notify_on_subscribe'] = #arguments.notify_on_subscribe#></cfif>
    <cfif isDefined('arguments.notify_on_unsubscribe')><cfset requestBody.contact['notify_on_unsubscribe'] = #arguments.notify_on_unsubscribe#></cfif>
    <cfset requestBody['email_type_option'] = #arguments.email_type_option#>
    <cfif isDefined('arguments.visibility')><cfset requestBody.contact['visibility'] = #arguments.visibility#></cfif>
    <cfinvoke method="apiCall" apiMethod="lists" httpMethod="post" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- GET LIST(S) --->
	<cffunction name="lists" access="public" returntype="any" hint="I get information about lists">
  	<cfargument name="list_id" required="no" type="string">
    <cfif isDefined('arguments.list_id')>
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="lists" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- EDIT LIST --->
	<cffunction name="listEdit" access="public" returntype="any" hint="I edit a list">
  	<cfargument name="list_id" required="yes" type="string">
		<cfargument name="name" required="yes" type="string">
    <cfargument name="company" required="yes" type="string">
    <cfargument name="address1" required="yes" type="string">
    <cfargument name="address2" required="no" type="string">
    <cfargument name="city" required="yes" type="string">
    <cfargument name="state" required="yes" type="string">
    <cfargument name="zip" required="yes" type="string">
    <cfargument name="country" required="yes" type="string">
    <cfargument name="phone" required="no" type="string">
    <cfargument name="permission_reminder" required="yes" type="string" default="You signed up for this list on our website">
		<cfargument name="use_archive_bar" required="no" type="boolean">
    <cfargument name="from_name" required="yes" type="string">
    <cfargument name="from_email" required="yes" type="string">
    <cfargument name="subject" required="yes" type="string">
    <cfargument name="language" required="yes" type="string">
    <cfargument name="notify_on_subscribe" required="no" type="string">
    <cfargument name="notify_on_unsubscribe" required="no" type="string">
    <cfargument name="email_type_option" required="yes" type="boolean">
    <cfargument name="visibility" required="no" type="string" default="pub">
		<cfset requestBody = {}>
    <cfset requestBody['name'] = #arguments.name#>
    <cfset requestBody['contact'] = {}>
    <cfset requestBody.contact['company'] = #arguments.company#>
    <cfset requestBody.contact['address1'] = #arguments.address1#>
    <cfif isDefined('arguments.address2')><cfset requestBody.contact['address2'] = #arguments.address2#></cfif>
		<cfset requestBody.contact['city'] = #arguments.city#>
    <cfset requestBody.contact['state'] = #arguments.state#>
    <cfset requestBody.contact['zip'] = #arguments.zip#>
    <cfset requestBody.contact['country'] = #arguments.country#>
    <cfif isDefined('arguments.phone')><cfset requestBody.contact['phone'] = #arguments.phone#></cfif>
		<cfset requestBody['permission_reminder'] = #arguments.permission_reminder#>
    <cfif isDefined('arguments.use_archive_bar')><cfset requestBody.contact['use_archive_bar'] = #arguments.use_archive_bar#></cfif>
    <cfset requestBody['campaign_defaults'] = {}>
    <cfset requestBody.campaign_defaults['from_name'] = #arguments.from_name#>
    <cfset requestBody.campaign_defaults['from_email'] = #arguments.from_email#>
    <cfset requestBody.campaign_defaults['subject'] = #arguments.subject#>
    <cfset requestBody.campaign_defaults['language'] = #arguments.language#>
    <cfif isDefined('arguments.notify_on_subscribe')><cfset requestBody.contact['notify_on_subscribe'] = #arguments.notify_on_subscribe#></cfif>
    <cfif isDefined('arguments.notify_on_unsubscribe')><cfset requestBody.contact['notify_on_unsubscribe'] = #arguments.notify_on_unsubscribe#></cfif>
    <cfset requestBody['email_type_option'] = #arguments.email_type_option#>
    <cfif isDefined('arguments.visibility')><cfset requestBody.contact['visibility'] = #arguments.visibility#></cfif>
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#" httpMethod="patch" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- DELETE LIST --->
	<cffunction name="listDelete" access="public" returntype="any" hint="I delete a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#" httpMethod="delete" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- GET LIST ABUSE REPORTS --->
	<cffunction name="listAbuseReports" access="public" returntype="any" hint="I get abuse reports for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="report_id" required="no" type="string">
    <cfif isDefined('arguments.report_id')>
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/abuse-reports/#arguments.report_id#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/abuse-reports" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- GET LIST ACTIVITY --->
	<cffunction name="listActivity" access="public" returntype="any" hint="I get activity stats for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/activity" httpMethod="get" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- GET LIST CLIENTS --->
	<cffunction name="listClients" access="public" returntype="any" hint="I get the most popular email clients for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/clients" httpMethod="get" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- GET LIST GROWTH HISTORY --->
	<cffunction name="listGrowthHistory" access="public" returntype="any" hint="I get growth history for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="month" required="no" type="string">
    <cfif isDefined('arguments.month')>
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/growth-history/#arguments.month#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/growth-history" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- CREATE LIST INTEREST CATEGORY --->
	<cffunction name="listInterestCategoriesCreate" access="public" returntype="any" hint="I create interest categories for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="title" required="yes" type="string">
    <cfargument name="display_order" required="no" type="numeric">
    <cfargument name="type" required="yes" type="string">
    <cfset requestBody = {}>
    <cfset requestBody['title'] = #arguments.title#>
    <cfif isDefined('arguments.display_order')><cfset requestBody['display_order'] = #arguments.title#></cfif>
    <cfset requestBody['type'] = #arguments.title#>
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/interest-categories" httpMethod="post" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- GET LIST INTEREST CATEGORIES --->
	<cffunction name="listInterestCategories" access="public" returntype="any" hint="I get interest categories for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="interest_category_id" required="no" type="string">
    <cfif isDefined('arguments.interest_category_id')>
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/interest-categories/#arguments.interest_category_id#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/interest-categories" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- EDIT LIST INTEREST CATEGORIES --->
	<cffunction name="listInterestCategoriesEdit" access="public" returntype="any" hint="I edit interest categories for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="interest_category_id" required="yes" type="string">
    <cfargument name="title" required="yes" type="string">
    <cfargument name="display_order" required="no" type="numeric">
    <cfargument name="type" required="yes" type="string">
    <cfset requestBody = {}>
    <cfset requestBody['title'] = #arguments.title#>
    <cfif isDefined('arguments.display_order')><cfset requestBody['display_order'] = #arguments.display_order#></cfif>
    <cfset requestBody['type'] = #arguments.title#>
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/interest-categories/#arguments.interest_category_id#" httpMethod="patch" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- DELETE LIST INTEREST CATEGORY --->
	<cffunction name="listInterestCategoriesDelete" access="public" returntype="any" hint="I delete interest categories for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="interest_category_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/interest-categories/#arguments.interest_category_id#" httpMethod="delete" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- GET INTERESTS --->
	<cffunction name="listInterests" access="public" returntype="any" hint="I get interests for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="interest_category_id" required="yes" type="string">
    <cfargument name="interest_id" required="no" type="string">
    <cfif isDefined('arguments.interest_id')>
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/interest-categories/#arguments.interest_category_id#/interests/#arguments.interest_id#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/interest-categories/#arguments.interest_category_id#/interests" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- EDIT INTERESTS --->
	<cffunction name="listInterestsEdit" access="public" returntype="any" hint="I edit interests for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="interest_category_id" required="yes" type="string">
    <cfargument name="interest_id" required="yes" type="string">
    <cfargument name="new_list_id" required="no" type="string">
    <cfargument name="name" required="yes" type="string">
    <cfargument name="subscriber_count" required="no" type="string">
    <cfargument name="display_order" required="no" type="numeric">
    <cfset requestBody = {}>
    <cfif isDefined('arguments.new_list_id')><cfset requestBody['list_id'] = #arguments.new_list_id#></cfif>
    <cfset requestBody['name'] = #arguments.name#>
    <cfif isDefined('arguments.subscriber_count')><cfset requestBody['subscriber_count'] = #arguments.subscriber_count#></cfif>
    <cfif isDefined('arguments.display_order')><cfset requestBody['display_order'] = #arguments.display_order#></cfif>
    <cfset requestBody['type'] = #arguments.title#>
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/interest-categories/#arguments.interest_category_id#/interests/#arguments.interest_id#" httpMethod="patch" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- DELETE INTEREST --->
	<cffunction name="listInterestDelete" access="public" returntype="any" hint="I delete an interest for a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="interest_category_id" required="yes" type="string">
    <cfargument name="interest_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/interest-categories/#arguments.interest_category_id#/interests/#arguments.interest_id#" httpMethod="delete" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
	
  <!--- CREATE MEMBER --->
	<cffunction name="listMemberCreate" access="public" returntype="any" hint="I subscribe the provided e-mail to a list">
		<cfargument name="list_id" required="yes" type="string">
    <cfargument name="email_address" required="yes" type="string">
    <cfargument name="email_type" required="no" type="string" default="html">
    <cfargument name="status" required="no" type="string" default="subscribed">
    <cfargument name="merge_fields" required="no" type="struct">
    <cfargument name="interests" required="no" type="struct">
    <cfargument name="language" required="no" type="string">
    <cfargument name="vip" required="no" type="boolean">
    <cfargument name="location" required="no" type="struct">
		<cfargument name="firstname" required="no" type="string">
		<cfargument name="lastname" required="no" type="string">
		<cfset requestBody = {}>
    <cfset requestBody['email_address'] = #email_address#>
    <cfif isDefined('arguments.email_type')><cfset requestBody['email_type'] = #arguments.email_type#></cfif>
    <cfif isDefined('arguments.status')><cfset requestBody['status'] = #arguments.status#></cfif>
    <cfif isDefined('arguments.merge_fields')>
			<cfset requestBody['merge_fields'] = {}>
      <cfloop collection="#arguments.merge_fields#" item="field">
				<cfset requestBody.merge_fields[field] = #arguments.merge_fields[field]#>
      </cfloop>
    </cfif>
    <cfif isDefined('arguments.ip_signup')><cfset requestBody['ip_signup'] = #cgi.REMOTE_ADDR#></cfif>
    <cfif isDefined('arguments.timestamp_signup')><cfset requestBody['timestamp_signup'] = "#DateFormat(NOW(), 'yyyy-mm-dd')# #TimeFormat(NOW(), 'hh:mm:ss')#"></cfif>
    <cfif isDefined('arguments.ip_opt')><cfset requestBody['ip_opt'] = #cgi.REMOTE_ADDR#></cfif>
    <cfif isDefined('arguments.timestamp_opt')><cfset requestBody['timestamp_opt'] = "#DateFormat(NOW(), 'yyyy-mm-dd')# #TimeFormat(NOW(), 'hh:mm:ss')#"></cfif>
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/members" httpMethod="post" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- GET LIST MEMBER(S) --->
	<cffunction name="listMember" access="public" returntype="any" hint="I list members of a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="email_address" required="no" type="string">
    <cfargument name="status" required="no" type="string">
    <cfif isDefined('arguments.email_address')>
    	<cfinvoke method="getMD5Hash" email_address="#arguments.email_address#" returnvariable="subscriber_hash">
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/members/#subscriber_hash#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/members/" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
	</cffunction>
	
  <!--- EDIT LIST MEMBER --->
  <cffunction name="listMemberEdit" access="public" returntype="any" hint="I update a members info on a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="email_address" required="yes" type="string">
    <cfargument name="email_type" required="no" type="string">
    <cfargument name="status" required="no" type="string">
    <cfargument name="merge_fields" required="no" type="struct">
    <cfargument name="interests" required="no" type="struct">
    <cfargument name="language" required="no" type="string">
    <cfargument name="vip" required="no" type="boolean">
    <cfargument name="location" required="no" type="struct">
	 	<cfset requestBody = {}>
    <cfif isDefined('arguments.email_type')><cfset requestBody['email_type'] = #arguments.email_type#></cfif>
    <cfif isDefined('arguments.status')><cfset requestBody['status'] = #arguments.status#></cfif>
    <cfif isDefined('arguments.merge_fields')>
			<cfset requestBody['merge_fields'] = {}>
      <cfloop collection="#arguments.merge_fields#" item="field">
				<cfset requestBody.merge_fields[field] = #arguments.merge_fields[field]#>
      </cfloop>
    </cfif>
    <cfif isDefined('arguments.interests')>
			<cfset requestBody['interests'] = {}>
      <cfloop collection="#arguments.interests#" item="field">
				<cfset requestBody.interests[field] = #arguments.interests[field]#>
      </cfloop>
    </cfif>
    <cfif isDefined('arguments.language')><cfset requestBody['language'] = #arguments.language#></cfif>
    <cfif isDefined('arguments.vip')><cfset requestBody['vip'] = #arguments.vip#></cfif>
    <cfif isDefined('arguments.location')>
			<cfset requestBody['location'] = {}>
      <cfloop collection="#arguments.location#" item="field">
				<cfset requestBody.location[field] = #arguments.location[field]#>
      </cfloop>
    </cfif>
    <cfinvoke method="getMD5Hash" email_address="#arguments.email_address#" returnvariable="subscriber_hash">
    <cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/members/#subscriber_hash#" httpMethod="put" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>

  <!--- UNSUBSCRIBE MEMBER --->
  <cffunction name="listMemberDelete" access="public" returntype="any" hint="I delete/unsubscribe members of a list">
  	<cfargument name="list_id" required="yes" type="string">
    <cfargument name="email_address" required="yes" type="string">
    <cfinvoke method="getMD5Hash" email_address="#arguments.email_address#" returnvariable="subscriber_hash">
	 	<cfinvoke method="apiCall" apiMethod="lists/#arguments.list_id#/members/#subscriber_hash#" httpMethod="delete" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
	
  <!---************************************************
	* CAMPAIGNS 
	* http://developer.mailchimp.com/documentation/mailchimp/reference/campaigns/
	*************************************************--->
  
	<!--- CREATE CAMPAIGN --->
	<cffunction name="campaignCreate" access="public" returntype="any" hint="I create a campaign">
		<cfargument name="type" required="yes" type="string" default="#this.options.type#">
		<cfargument name="list_id" required="yes" type="string">
		<cfargument name="subject_line" required="yes" type="string">
    <cfargument name="title" required="no" type="string">
		<cfargument name="from_name" required="yes" type="string">
    <cfargument name="reply_to" required="yes" type="string">
    <cfargument name="use_conversation" required="no" type="boolean">
		<cfargument name="to_name" required="no" type="string">
    <cfargument name="folder_id" required="no" type="string">
    <cfargument name="authenticate" required="no" type="boolean" default="true">
    <cfargument name="auto_footer" required="no" type="boolean">
    <cfargument name="inline_css" required="no" type="boolean">
    <cfargument name="auto_tweet" required="no" type="boolean" default="false">
    <cfargument name="auto_fb_post" required="no" type="array">
    <cfargument name="fb_comments" required="no" type="boolean">
    <cfargument name="opens" required="no" type="boolean" default="true">
    <cfargument name="html_clicks" required="no" type="boolean" default="true">
    <cfargument name="text_clicks" required="no" type="boolean" default="false">
  	<cfset requestBody = {}>
    <cfset requestBody['type'] = #arguments.type#>
    <cfset requestBody['recipients'] = {}>
    <cfset requestBody.recipients['list_id'] = #arguments.list_id#>
    <cfset requestBody['settings'] = {}>
    <cfset requestBody.settings['subject_line'] = #arguments.subject_line#>
    <cfif isDefined('arguments.title')><cfset requestBody.settings['title'] = #arguments.title#><cfelse><cfset requestBody.settings['title'] = #arguments.subject_line#></cfif>
    <cfset requestBody.settings['from_name'] = #arguments.from_name#>
    <cfset requestBody.settings['reply_to'] = #arguments.reply_to#>
    <cfif isDefined('arguments.use_conversation')><cfset requestBody.settings['use_conversation'] = #arguments.use_conversation#></cfif>
    <cfif isDefined('arguments.to_name')><cfset requestBody.settings['to_name'] = #arguments.to_name#></cfif>
    <cfif isDefined('arguments.folder_id')><cfset requestBody.settings['folder_id'] = #arguments.folder_id#></cfif>
    <cfset requestBody.settings['authenticate'] = #arguments.authenticate#>
    <cfif isDefined('arguments.auto_footer')><cfset requestBody.settings['auto_footer'] = #arguments.auto_footer#></cfif>
    <cfif isDefined('arguments.inline_css')><cfset requestBody.settings['inline_css'] = #arguments.inline_css#></cfif>
    <cfif isDefined('arguments.auto_tweet')>
			<cfset requestBody.settings['auto_tweet'] = #arguments.auto_tweet#>
		<cfelseif isDefined('this.options.twitter') AND #this.options.twitter# NEQ false>
    	<cfset requestBody.settings['auto_tweet'] = true>
    </cfif>
    <cfif isDefined('arguments.auto_fb_post')>
      <cfset requestBody.settings['auto_fb_post'] = #arguments.auto_fb_post#>
    <cfelseif isDefined('this.options.facebook') AND #this.options.facebook# NEQ ''>
    	<cfset requestBody.settings['auto_fb_post'] = []>
      <cfset requestBody.settings['auto_fb_post'] = ListToArray(this.options.facebook)>
    </cfif>
    <cfif isDefined('arguments.fb_comments')><cfset requestBody.settings['fb_comments'] = #arguments.fb_comments#></cfif>
    <cfset requestBody['tracking'] = {}>
    <cfset requestBody.tracking['opens'] = #arguments.opens#>
    <cfset requestBody.tracking['html_clicks'] = #arguments.html_clicks#>
    <cfset requestBody.tracking['text_clicks'] = #arguments.text_clicks#>
    <cfinvoke method="apiCall" apiMethod="campaigns" httpMethod="post" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- GET CAMPAIGN(S) --->
  <cffunction name="campaignList" access="public" returntype="any" hint="I list all campaigns or a specific campaign">
  	<cfargument name="campaign_id" required="no" type="string">
    <cfif isDefined('arguments.campaign_id')>
    	<cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="campaigns" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- EDIT CAMPAIGN --->
  <cffunction name="campaignEdit" access="public" returntype="any" hint="I edit a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfargument name="type" required="yes" type="string" default="#this.options.type#">
		<cfargument name="list_id" required="yes" type="string">
		<cfargument name="subject_line" required="yes" type="string">
    <cfargument name="title" required="no" type="string">
		<cfargument name="from_name" required="yes" type="string">
    <cfargument name="reply_to" required="yes" type="string">
    <cfargument name="use_conversation" required="no" type="boolean">
		<cfargument name="to_name" required="no" type="string">
    <cfargument name="folder_id" required="no" type="string">
    <cfargument name="authenticate" required="no" type="boolean" default="true">
    <cfargument name="auto_footer" required="no" type="boolean">
    <cfargument name="inline_css" required="no" type="boolean">
    <cfargument name="auto_tweet" required="no" type="boolean" default="false">
    <cfargument name="auto_fb_post" required="no" type="array">
    <cfargument name="fb_comments" required="no" type="boolean">
    <cfargument name="opens" required="no" type="boolean" default="true">
    <cfargument name="html_clicks" required="no" type="boolean" default="true">
    <cfargument name="text_clicks" required="no" type="boolean" default="false">
  	<cfset requestBody = {}>
    <cfset requestBody['type'] = #arguments.type#>
    <cfset requestBody['recipients'] = {}>
    <cfset requestBody.recipients['list_id'] = #arguments.list_id#>
    <cfset requestBody['settings'] = {}>
    <cfset requestBody.settings['subject_line'] = #arguments.subject_line#>
    <cfif isDefined('arguments.title')><cfset requestBody.settings['title'] = #arguments.title#><cfelse><cfset requestBody.settings['title'] = #arguments.subject_line#></cfif>
    <cfset requestBody.settings['from_name'] = #arguments.from_name#>
    <cfset requestBody.settings['reply_to'] = #arguments.reply_to#>
    <cfif isDefined('arguments.use_conversation')><cfset requestBody.settings['use_conversation'] = #arguments.use_conversation#></cfif>
    <cfif isDefined('arguments.to_name')><cfset requestBody.settings['to_name'] = #arguments.to_name#></cfif>
    <cfif isDefined('arguments.folder_id')><cfset requestBody.settings['folder_id'] = #arguments.folder_id#></cfif>
    <cfset requestBody.settings['authenticate'] = #arguments.authenticate#>
    <cfif isDefined('arguments.auto_footer')><cfset requestBody.settings['auto_footer'] = #arguments.auto_footer#></cfif>
    <cfif isDefined('arguments.inline_css')><cfset requestBody.settings['inline_css'] = #arguments.inline_css#></cfif>
    <cfif isDefined('arguments.auto_tweet')>
			<cfset requestBody.settings['auto_tweet'] = #arguments.auto_tweet#>
		<cfelseif isDefined('this.options.twitter') AND #this.options.twitter# NEQ false>
    	<cfset requestBody.settings['auto_tweet'] = true>
    </cfif>
    <cfif isDefined('arguments.auto_fb_post')>
      <cfset requestBody.settings['auto_fb_post'] = #arguments.auto_fb_post#>
    <cfelseif isDefined('this.options.facebook') AND #this.options.facebook# NEQ ''>
    	<cfset requestBody.settings['auto_fb_post'] = []>
      <cfset requestBody.settings['auto_fb_post'] = ListToArray(this.options.facebook)>
    </cfif>
    <cfif isDefined('arguments.fb_comments')><cfset requestBody.settings['fb_comments'] = #arguments.fb_comments#></cfif>
    <cfset requestBody['tracking'] = {}>
    <cfset requestBody.tracking['opens'] = #arguments.opens#>
    <cfset requestBody.tracking['html_clicks'] = #arguments.html_clicks#>
    <cfset requestBody.tracking['text_clicks'] = #arguments.text_clicks#>
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#" httpMethod="patch" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- DELETE CAMPAIGN --->
  <cffunction name="campaignDelete" access="public" returntype="any" hint="I delete a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#" httpMethod="delete" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- CANCEL SENDING OF CAMPAIGN --->
  <cffunction name="campaignCancel" access="public" returntype="any" hint="I cancel sending of a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#/actions/cancel-send" httpMethod="post" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- PAUSE CAMPAIGN --->
  <cffunction name="campaignPause" access="public" returntype="any" hint="I pause sending of a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#/actions/pause" httpMethod="post" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- REPLICATE CAMPAIGN --->
  <cffunction name="campaignReplicate" access="public" returntype="any" hint="I replicate a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#/actions/replicate" httpMethod="post" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- RESUME CAMPAIGN --->
  <cffunction name="campaignResume" access="public" returntype="any" hint="I resume sending of a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#/actions/resume" httpMethod="post" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- SCHEDULE CAMPAIGN --->
  <cffunction name="campaignSchedule" access="public" returntype="any" hint="I schedule sending of a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfargument name="date" required="yes" type="string">
    <cfargument name="time" required="yes" type="string">
    <cfargument name="timewarp" required="no" type="boolean" default="false">
    <cfset roundedMinute = round(minute(time) / 15 ) * 15>
    <cfset roundedMinute = #NumberFormat(roundedMinute,'00')#>
    <cfset roundedHour = hour(time)>
    <cfif roundedMinute EQ 60>
    	<cfset roundedHour = hour(time) + 1>
      <cfset roundedMinute = "00">
    </cfif>
    <cfoutput>#roundedHour#:#roundedMinute#:00</cfoutput>
    <cfset roundedTime = #DateConvert("Local2UTC","#roundedHour#:#roundedMinute#:00")#>
    <cfset roundedTime = #Timeformat(roundedTime,"hh:mm:ss")#>
    <cfset schedule_time = "#DateFormat(arguments.date,'yyyy-mm-dd')# #roundedTime#">
    <cfset requestBody = {}>
    <cfset requestBody['schedule_time'] = #schedule_time#>
    <cfset requestBody['timewarp'] = #arguments.timewarp#>
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#/actions/schedule" httpMethod="post" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- SEND CAMPAIGN --->
  <cffunction name="campaignSend" access="public" returntype="any" hint="I send a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#/actions/send" httpMethod="post" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- TEST CAMPAIGN --->
  <cffunction name="campaignTest" access="public" returntype="any" hint="I send test a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfargument name="test_emails" required="yes" type="string">
    <cfargument name="send_type" required="no" type="string" default="html">
    <cfset requestBody = {}>
    <cfset requestBody['test_emails'] = []>
    <cfset requestBody.test_emails = ListToArray(arguments.test_emails)>
    <cfset requestBody['send_type'] = #arguments.send_type#>
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#/actions/test" httpMethod="post" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>

  <!--- UNSCHEDULE CAMPAIGN --->
  <cffunction name="campaignUnschedule" access="public" returntype="any" hint="I unschedule sending of a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#/actions/unschedule" httpMethod="post" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- GET CAMPAIGN CONTENT --->
  <cffunction name="campaignContent" access="public" returntype="any" hint="I get a campaigns content">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#/content" httpMethod="get" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- EDIT CAMPAIGN CONTENT --->
  <cffunction name="campaignContentEdit" access="public" returntype="any" hint="I edit a campaigns content">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfargument name="html" required="no" type="string">
    <cfargument name="sections" required="no" type="string">
    <cfset requestBody = {}>
    <cfif isDefined('this.options.template_id') AND #this.options.template_id# NEQ '' AND isDefined('arguments.sections') AND #arguments.sections# NEQ ''>
			<cfset requestBody['template'] = {}>
      <cfset requestBody.template['id'] = #this.options.template_id#>
      <cfset requestBody.template['sections'] = {}>
      <cfset requestBody.template.sections[#arguments.sections#] = #arguments.html#>
    <cfelseif isDefined('this.options.template_id') AND #this.options.template_id# NEQ '' AND isDefined('this.options.sections') AND #this.options.sections# NEQ ''>
    	<cfset requestBody['template'] = {}>
      <cfset requestBody.template['id'] = #this.options.template_id#>
      <cfset requestBody.template['sections'] = {}>
      <cfset requestBody.template.sections[#this.options.sections#] = #arguments.html#>
    <cfelse>
    	<cfset requestBody['html'] = #arguments.html#>
    </cfif>
    <cfinvoke method="apiCall" apiMethod="campaigns/#arguments.campaign_id#/content" httpMethod="put" requestBody="#requestBody#" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!---************************************************
	* REPORTS 
	* http://developer.mailchimp.com/documentation/mailchimp/reference/reports/
	*************************************************--->
  
  <!--- REPORT CAMPAIGN(S) --->
	<cffunction name="reports" access="public" returntype="any" hint="I get campaign reports">
  	<cfargument name="campaign_id" required="no" type="string">
    <cfif isDefined('arguments.campaign_id')>
    	<cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="reports" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
	</cffunction>
  
  <!--- REPORT CAMPAIGN ADVICE --->
  <cffunction name="reportAdvice" access="public" returntype="any" hint="I report advice for a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/advice" httpMethod="get" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- REPORT CLICKS --->
  <cffunction name="reportClicks" access="public" returntype="any" hint="I report clicks for a campaign">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfargument name="link_id" required="no" type="string">
    <cfif isDefined('arguments.link_id')>
    	<cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/click-details/#arguments.link_id#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/click-details" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- REPORT DOMAIN PERFORMANCE --->
  <cffunction name="reportDomainPerformance" access="public" returntype="any" hint="I report domain performance">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/domain-performance" httpMethod="get" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
 	<!--- REPORT EEPURL --->
  <cffunction name="reportEepURL" access="public" returntype="any" hint="I report EepURL">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/eepurl" httpMethod="get" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- REPORT EMAIL ACTIVITY --->
  <cffunction name="reportEmailActivity" access="public" returntype="any" hint="I report email activity">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfargument name="email_address" required="no" type="string">
    <cfif isDefined('arguments.email_address')>
    	<cfinvoke method="getMD5Hash" email_address="#arguments.email_address#" returnvariable="subscriber_hash">
    	<cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/email-activity/#subscriber_hash#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/email-activity" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- REPORT LOCATIONS --->
  <cffunction name="reportLocations" access="public" returntype="any" hint="I report locations">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/locations" httpMethod="get" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- REPORT SENT TO --->
  <cffunction name="reportSentTo" access="public" returntype="any" hint="I report details about campaign recipients">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfargument name="email_address" required="no" type="string">
    <cfif isDefined('arguments.email_address')>
    	<cfinvoke method="getMD5Hash" email_address="#arguments.email_address#" returnvariable="subscriber_hash">
    	<cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/sent-to/#subscriber_hash#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/sent-to" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- REPORT SUB-REPORTS --->
  <cffunction name="reportSubReports" access="public" returntype="any" hint="I report child campaign reports">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/sub-reports" httpMethod="get" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
  <!--- REPORT UNSUBSCRIBES --->
  <cffunction name="reportUnsubscribes" access="public" returntype="any" hint="I report information on members who unsubscribed">
  	<cfargument name="campaign_id" required="yes" type="string">
    <cfargument name="email_address" required="no" type="string">
    <cfif isDefined('arguments.email_address')>
    	<cfinvoke method="getMD5Hash" email_address="#arguments.email_address#" returnvariable="subscriber_hash">
    	<cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/unsubscribed/#subscriber_hash#" httpMethod="get" returnvariable="returnStruct">
    <cfelse>
    	<cfinvoke method="apiCall" apiMethod="reports/#arguments.campaign_id#/unsubscribed" httpMethod="get" returnvariable="returnStruct">
    </cfif>
    <cfreturn returnStruct>
  </cffunction>
  
  <!---************************************************
	* TEMPLATES 
	* http://developer.mailchimp.com/documentation/mailchimp/reference/templates/
	*************************************************--->
  
  <!--- GET TEMPLATE DEFAULT CONTENT --->
  <cffunction name="templateContent" access="public" returntype="any" hint="I get a template's content">
  	<cfargument name="template_id" required="yes" type="string">
    <cfinvoke method="apiCall" apiMethod="templates/#arguments.template_id#/default-content" httpMethod="get" returnvariable="returnStruct">
    <cfreturn returnStruct>
  </cffunction>
  
</cfcomponent>