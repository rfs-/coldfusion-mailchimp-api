# coldfusion-mailchimp-api
Coldfusion Mailchimp API v3

##Usage
#####Initialize
`<cfscript>
  application.cfc_mailing = createObject("component","mailchimp").init();
</cfscript>`

#####Example call to list all campaigns
`<cfinvoke component="#application.cfc_mailing#" method="campaignList" returnvariable="campaignList"></cfinvoke>`

#####Example call to create a campaign and also update it's body content
`<cfinvoke component="#application.cfc_mailing#" method="campaignCreate" list_id="#application.cfc_mailing.options.list_id#" returnvariable="campaignCreate" argumentcollection="#form#"></cfinvoke>`

`<cfinvoke component="#application.cfc_mailing#" method="campaignContentEdit" campaign_id="#campaignCreate.id#" returnvariable="campaignContentEdit" argumentcollection="#form#"></cfinvoke>`

##Current Methods
#### LISTS
* Create List
* Get List(s)
* Edit List
* Delete List
* Get List Abuse Reports
* Get List Activity
* Get List Clients
* Get List Growth History
* Create List Interest Category
* Get List Interest Categories
* Edit List Interest Categories
* Delete List Interest Category
* Get Interests
* Edit Interests
* Delete Interest
* Create Member
* Get List Member(s)
* Edit List Member
* Unsubscribe Member

#### CAMPAIGNS
* Create Campaign
* Get Campaign(s)
* Edit Campaign
* Delete Campaign
* Cancel Sending of Campaign
* Pause Campaign
* Replicate Campaign
* Resume Campaign
* Schedule Campaign
* Send Campaign
* Test Campaign
* Unschedule Campaign
* Get Campaign Content
* Edit Campaign Content

#### REPORTS
* Report Campaign(s)
* Report Campaign Advice
* Report Clicks
* Report Domain Performance
* Report EEPURL
* Report Email Activity
* Report Locations
* Report Sent To
* Report Sub Reports
* Report Unsubscribes

#### TEMPLATES
* Get Template Default Content

##Notes
Not all methods are completely tested. Some methods don't exist yet in API v3.

##API Reference Documentation
http://developer.mailchimp.com/documentation/mailchimp/reference/overview/
