set echo on
spool table_row_count.lst
select count(*) from ACTIVATION_BIZ_RULE_SETS;
select count(*) from ACTIVATION_DEVICE_RULE_SETS;
select count(*) from ACTIVATION_RULES;
select count(*) from ADAPTER;
select count(*) from ADAPTER_METADATA;
select count(*) from APACHEWEBSERVER;
select count(*) from APACHEWEBSERVICE;
select count(*) from ASSOCIATEDRELAYAGENT;
select count(*) from ASSOCIATEDSCOPES;
select count(*) from ASSURANCE;
select count(*) from ASSURANCETODEVICE;
select count(*) from BINDING;
select count(*) from BINFILE;
select count(*) from BIZFLOW;
select count(*) from BIZFLOW_METADATA;
select count(*) from CABLEHOME;
select count(*) from CABLEHOMEIMAGEPARAMS;
select count(*) from CABLEHOME_IMAGE_FILE;
select count(*) from CEDARPOINT;
select count(*) from CEDARPOINTCMS;
select count(*) from CGPRO;
select count(*) from CMINVENTORY;
select count(*) from CMMONITORTABLE;
select count(*) from CMQUERYTABLE;
select count(*) from CMTSCMTABLE;
select count(*) from CMTSTABLE;
select count(*) from CMVERSIONINFO;
select count(*) from CM_IMAGE_CONTENT;
select count(*) from CM_SERVICE_CODES;
select count(*) from CM_VENDOR_TYPE;
select count(*) from CNRDHCP;
select count(*) from CNRFAILOVER;
select count(*) from CNRPOOLGROUP;
select count(*) from COM21;
select count(*) from COM21COMCONTROLLER;
select count(*) from CONFIGDB;
select count(*) from CONTAINSANYVALUE;
select count(*) from COSNAMING;
select count(*) from CPEDETAILS;
select count(*) from CSGEMAILMAP;
select count(*) from CSGPACKAGES;
select count(*) from CSGUPSTREAM;
select count(*) from CSG_SERVICE_STATUS;
select count(*) from DEPACCESSLOG;
select count(*) from DEPLOY;
select count(*) from DEPLOYEDDEVICES;
select count(*) from DEPLOYEDLOCATIONS;
select count(*) from DEPLOYMENTACL;
select count(*) from DEPLOYMENTLOCK;
select count(*) from DEPLOYMENT_DEVICE_INFO;
select count(*) from DEVICEDEPLOYMENT;
select count(*) from DEVICEDETAILS;
select count(*) from DEVICEPARAMSDEPLOYMENT;
select count(*) from DEVICES;
select count(*) from DHCP;
select count(*) from DISPATCH_INFO;
select count(*) from DOCSISCMTS;
select count(*) from DOCSIS_IMAGE_FILE;
select count(*) from DOMAIN;
select count(*) from DOWNSTREAM;
select count(*) from DQOSPROFILE;
select count(*) from DSTREE;
select count(*) from EMAIL;
select count(*) from ENDPOINT;
select count(*) from EVENT_TXN;
select count(*) from FAILOVER;
select count(*) from GENERICCMS;
select count(*) from GLOBALINTERVAL;
select count(*) from HEADEND_BNODE_LOCATION;
select count(*) from HOMEEXCHANGE;
select count(*) from HSD;
select count(*) from HSD_174610;
select count(*) from HSD_183003;
select count(*) from HSD_185120;
select count(*) from ID_GENERATOR;
select count(*) from IMAGEPARAMS;
select count(*) from IMERGE;
select count(*) from INDIVIDUALPOLLINTERVAL;
select count(*) from IPBLOCK;
select count(*) from IPLANET;
select count(*) from IPRANGE;
select count(*) from IP_ALLOCATION_EVENTS_NO_PART;
select count(*) from LICENSE;
select count(*) from LICENSE_LIMITS_TABLE;
select count(*) from LOCATIONINFO;
select count(*) from LOCATIONTREE;
select count(*) from LOCATION_LIST;
select count(*) from MACADDRESS_FQDN;
select count(*) from MACPATTERN_COMM_STR;
select count(*) from MCS_ADDRESS_DETAILS;
select count(*) from MCS_AUDIO_DEVICE;
select count(*) from MCS_CD_INFO;
select count(*) from MCS_CM_INFO;
select count(*) from MCS_CPU;
select count(*) from MCS_DHCP_DETAILS;
select count(*) from MCS_DNS_DETAILS;
select count(*) from MCS_EMAIL_INFO;
select count(*) from MCS_FIXED;
select count(*) from MCS_HARD_DRIVE;
select count(*) from MCS_HTTPPROT_TEST;
select count(*) from MCS_INSTALL_REPORT;
select count(*) from MCS_INTERFACE_INFO;
select count(*) from MCS_INTERNET_CONFIGURATION;
select count(*) from MCS_MEMORY;
select count(*) from MCS_OS;
select count(*) from MCS_PC_INFO;
select count(*) from MCS_PING_TEST;
select count(*) from MCS_POP3PROT_TEST;
select count(*) from MCS_PROFILE_INFO;
select count(*) from MCS_SMTPPROT_TEST;
select count(*) from MCS_SUBSCRIBER_INFO;
select count(*) from MCS_TRACEROUTE_TEST;
select count(*) from MCS_VIDEO_DEVICE;
select count(*) from MCXINDEX;
select count(*) from METASERV_EVENTS;
select count(*) from METASERV_EVENTS_NO_PART;
select count(*) from MSGROUPACCESSFILTER;
select count(*) from MSGROUPS;
select count(*) from MSLICENSE;
select count(*) from MSOPERATIONS;
select count(*) from MSPERMISSIONS;
select count(*) from MSUSER2GROUP;
select count(*) from MSUSERACCESSFILTER;
select count(*) from MSUSERS;
select count(*) from MSVIEWS;
select count(*) from MTAIMAGEPARAMS;
select count(*) from MTAPROFILE;
select count(*) from MTA_IMAGE_CONTENT;
select count(*) from MTA_IMAGE_FILE;
select count(*) from MTA_IMAGE_FILE_02SEP;
select count(*) from NET2PHONE;
select count(*) from NET2PHONEACCOUNT;
select count(*) from NUERA;
select count(*) from NUMCPE;
select count(*) from OPTIONCODE;
select count(*) from OPTIONSET;
select count(*) from OVERLOADFACTOR;
select count(*) from PACKAGE;
select count(*) from PACKAGEDEPLOYMENT;
select count(*) from PACKAGETODEVICE;
select count(*) from PACKAGETOSERVICEIMPL;
select count(*) from PACKAGE_METADATA;
select count(*) from PARENTALCONTROL;
select count(*) from PI;
select count(*) from PI_ADAPTER_IDS;
select count(*) from POOL;
select count(*) from POOLGROUP;
select count(*) from PORTNOPATCHINDEX;
select count(*) from PSPARAMS;
select count(*) from PSRECORD;
select count(*) from QMAIL;
select count(*) from QMAILDOMAIN;
select count(*) from REG;
select count(*) from REG_METADATA;
select count(*) from RELAYAGENT;
select count(*) from RESERVED_PHONES;
select count(*) from ROLLBACKDATA;
select count(*) from RULES_ACTION_PARAMS;
select count(*) from RULES_CONDITIONS;
select count(*) from RULES_RULECONDITIONS;
select count(*) from RULES_RULEINFO;
select count(*) from RULES_RULESET_MASTER;
select count(*) from RULES_RULESET_RULES;
select count(*) from RULES_RULETABLE;
select count(*) from SCOPES;
select count(*) from SEARCH_QUERY;
select count(*) from SERVICE;
select count(*) from SERVICEIMPL_POLICIES;
select count(*) from SERVICE_METADATA;
select count(*) from SERVICE_RULES;
select count(*) from SERVICE_TXN;
select count(*) from SESSIONDB;
select count(*) from SESSIONEVENT;
select count(*) from STATEZIPCODE;
select count(*) from SUBSCRIBER;
select count(*) from SUBSCRIBERPROXY;
select count(*) from SUBSCRIBERTOPACKAGE;
select count(*) from SUBSCRIBER_EVENTS;
select count(*) from SUBS_SERVICE_TO_DEVICE;
select count(*) from SURGEMAIL;
select count(*) from UPSTREAM;
select count(*) from VENDOR;
select count(*) from VENDOR_MACPATTERN;
select count(*) from VENDOR_TYPE;
select count(*) from VOICE;
select count(*) from VOICEMAILSERVER;