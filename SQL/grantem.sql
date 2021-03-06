create user rblack identified by rblack
default tablespace users temporary tablespace temp;

grant connect,resource to rblack;

grant select on CHINOOK_BILL_SEPTEMBER                                                           to rblack;
grant select on QWEST_DATA                                                                       to rblack;
grant select on CHINOOK_BILL_OCTOBER_ALT                                                         to rblack;
grant select on CHINOOK_SEPTEMBER                                                                to rblack;
grant select on CHINOOK_BILL_AUGUST                                                              to rblack;
grant select on CHINOOK_DATA                                                                     to rblack;
grant select on QWEST_SEPTEMBER                                                                  to rblack;
grant select on CHINOOK_BILLRUN_AUGUST                                                           to rblack;
grant select on CHINOOK_OCTOBER                                                                  to rblack;
grant select on CHINOOK_AUGUST                                                                   to rblack;
grant select on QWEST_AUGUST                                                                     to rblack;
grant select on QWEST_OCTOBER                                                                    to rblack;
grant select on CHINOOK_BILL_AUGUST_ALT                                                          to rblack;
grant select on CHINOOK_BILL_OCTOBER                                                             to rblack;
grant select on CHINOOK_BILL_SEPTEMBER_ALT                                                       to rblack;
grant select on CHINOOK_BILL_NOVEMBER                                                            to rblack;
grant select on QWEST_NOVEMBER                                                                   to rblack;
grant select on CHINOOK_NOVEMBER                                                                 to rblack;
grant select on QWEST_                                                                           to rblack;
grant select on QWEST_JANUARY                                                                    to rblack;
grant select on QWEST_DECEMBER                                                                   to rblack;
grant select on CHINOOK_DECEMBER                                                                 to rblack;
grant select on CHINOOK_BILL_DECEMBER                                                            to rblack;
grant select on CHINOOK_JANUARY                                                                  to rblack;
grant select on CHINOOK_BILL_NOVEMBER_AGAIN                                                      to rblack;
grant select on QWEST_MARCH                                                                      to rblack;
grant select on CHINOOK_BILL_JANUARY                                                             to rblack;
grant select on QWEST_APRIL                                                                      to rblack;
grant select on QWEST_FEBRUARY                                                                   to rblack;
grant select on CHINOOK_                                                                         to rblack;
grant select on CHINOOK_BILL_                                                                    to rblack;
grant select on CHINOOK_APRIL                                                                    to rblack;
grant select on CHINOOK_BILL_APRIL                                                               to rblack;
grant select on CHINOOK_MARCH                                                                    to rblack;
grant select on CHINOOK_BILL_MARCH                                                               to rblack;
grant select on QWEST_200803                                                                     to rblack;
grant select on CHINOOK_200803                                                                   to rblack;
grant select on CHINOOK_BILL_200803                                                              to rblack;
grant select on CARRIER_BILL_QWEST                                                               to rblack;
grant select on QWEST_AUGUST_2008                                                                to rblack;
grant select on CHINOOK_AUGUST_2008                                                              to rblack;
grant select on CHINOOK_BILL_AUGUST_2008                                                         to rblack;
grant select on CHINOOK_APRIL_2008                                                               to rblack;
grant select on CHINOOK_FEBRUARY_2008                                                            to rblack;
grant select on CHINOOK_BILL_FEBRUARY_2008                                                       to rblack;
grant select on QWEST_JANUARY_2008                                                               to rblack;
grant select on QWEST_FEBRUARY_2008                                                              to rblack;
grant select on QWEST_MARCH_2008                                                                 to rblack;
grant select on CHINOOK_MARCH_2008                                                               to rblack;
grant select on CHINOOK_BILL_MARCH_2008                                                          to rblack;
grant select on QWEST_APRIL_2008                                                                 to rblack;
grant select on CHINOOK_BILL_APRIL_2008                                                          to rblack;
grant select on CHINOOK_JANUARY_2008                                                             to rblack;
grant select on CHINOOK_BILL_JANUARY_2008                                                        to rblack;
grant select on QWEST_MAY_2008                                                                   to rblack;
grant select on CHINOOK_MAY_2008                                                                 to rblack;
grant select on CHINOOK_BILL_MAY_2008                                                            to rblack;
grant select on QWEST_JUNE_2008                                                                  to rblack;
grant select on QWEST_JULY_2008                                                                  to rblack;
grant select on CHINOOK_JUNE_2008                                                                to rblack;
grant select on CHINOOK_JULY_2008                                                                to rblack;
grant select on CHINOOK_BILL_JUNE_2008                                                           to rblack;
grant select on CHINOOK_BILL_JULY_2008                                                           to rblack;
grant select on QWEST_APRIL_2009                                                                 to rblack;
grant select on CHINOOK_APRIL_2009                                                               to rblack;
grant select on CHINOOK_BILL_APRIL_2009                                                          to rblack;
grant select on CHINOOK_HEALTH_CHECK_DEC_2008                                                    to rblack;
grant select on CHINOOK_HEALTH_CHECK_JAN_2009                                                    to rblack;
grant select on CHINOOK_HEALTH_CHECK_FEB_2009                                                    to rblack;
grant select on CHINOOK_HEALTH_CHECK_MAR_2009                                                    to rblack;
grant select on CHINOOK_HEALTH_CHECK_APR_2009                                                    to rblack;
grant select on CHINOOK_HEALTH_CHECK_NOV_2008                                                    to rblack;
grant select on QWEST_MAY_2009                                                                   to rblack;
grant select on CHINOOK_MAY_2009                                                                 to rblack;
grant select on CHINOOK_BILL_MAY_2009                                                            to rblack;
grant select on QWEST_SEPTEMBER_2008                                                             to rblack;
grant select on CHINOOK_SEPTEMBER_2008                                                           to rblack;
grant select on CHINOOK_BILL_SEPTEMBER_2008                                                      to rblack;
grant select on RERUN_CHINOOK_AUGUST_2007                                                        to rblack;
grant select on RERUN_CHINOOK_BILL_AUGUST_2007                                                   to rblack;
grant select on QWEST_OCTOBER_2008                                                               to rblack;
grant select on CHINOOK_OCTOBER_2008                                                             to rblack;
grant select on CHINOOK_BILL_OCTOBER_2008                                                        to rblack;
grant select on QWEST_OCTOBER_2007                                                               to rblack;
grant select on QWEST_SEPTEMBER_2007                                                             to rblack;
grant select on QWEST_NOVEMBER_2007                                                              to rblack;
grant select on QWEST_DECEMBER_2007                                                              to rblack;
grant select on QWEST_MARCH_2009                                                                 to rblack;
grant select on CHINOOK_MARCH_2009                                                               to rblack;
grant select on CHINOOK_BILL_MARCH_2009                                                          to rblack;
grant select on QWEST_JULY_2007                                                                  to rblack;
grant select on CHINOOK_JULY_2007                                                                to rblack;
grant select on CHINOOK_BILL_JULY_2007                                                           to rblack;
grant select on CHINOOK_BILL_SEPTEMBER_2007                                                      to rblack;
grant select on CHINOOK_SEPTEMBER_2007                                                           to rblack;
grant select on QWEST_AUGUST_2007                                                                to rblack;
grant select on CHINOOK_AUGUST_2007                                                              to rblack;
grant select on CHINOOK_BILL_AUGUST_2007                                                         to rblack;
grant select on CHINOOK_OCTOBER_2007                                                             to rblack;
grant select on CHINOOK_BILL_OCTOBER_2007                                                        to rblack;
grant select on CHINOOK_NOVEMBER_2007                                                            to rblack;
grant select on CHINOOK_BILL_NOVEMBER_2007                                                       to rblack;
grant select on CHINOOK_DECEMBER_2007                                                            to rblack;
grant select on CHINOOK_BILL_DECEMBER_2007                                                       to rblack;
grant select on QWEST_NOVEMBER_2008                                                              to rblack;
grant select on QWEST_DECEMBER_2008                                                              to rblack;
grant select on CHINOOK_DECEMBER_2008                                                            to rblack;
grant select on CHINOOK_BILL_DECEMBER_2008                                                       to rblack;
grant select on CHINOOK_NOVEMBER_2008                                                            to rblack;
grant select on CHINOOK_BILL_NOVEMBER_2008                                                       to rblack;
grant select on QWEST_JANUARY_2009                                                               to rblack;
grant select on CHINOOK_JANUARY_2009                                                             to rblack;
grant select on CHINOOK_BILL_JANUARY_2009                                                        to rblack;
grant select on QWEST_FEBRUARY_2009                                                              to rblack;
grant select on CHINOOK_FEBRUARY_2009                                                            to rblack;
grant select on CHINOOK_BILL_FEBRUARY_2009                                                       to rblack;
grant select on CHINOOK_HEALTH_CHECK                                                             to rblack;
grant select on CHINOOK_HEALTH_CHECK_SEP                                                         to rblack;
grant select on CHINOOK_HEALTH_CHECK_NOV                                                         to rblack;
grant select on CHINOOK_BILL_JUNE_2009                                                           to rblack;
grant select on QWEST_JUNE_2009                                                                  to rblack;
grant select on CHINOOK_JUNE_2009                                                                to rblack;
