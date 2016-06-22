# coldfusion-mailchimp-api
Coldfusion Mailchimp API v3

##Usage
`<cfscript>
  application.cfc_mailing = createObject("component","mailchimp").init();
</cfscript>`

`<cfinvoke component="#application.cfc_mailing#" method="campaignList" returnvariable="campaignList"></cfinvoke>`

##Notes
Not completely tested. Some methods don't exist yet in API v3

##API Reference Documentation
http://developer.mailchimp.com/documentation/mailchimp/reference/overview/
