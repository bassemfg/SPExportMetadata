using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SharePoint;
using System.IO;
using System.Configuration;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {

            string RootSiteCollection = System.Configuration.ConfigurationSettings.AppSettings["RootSiteCollection"];
            //int i = 0;
            int j = 0;
            Microsoft.SharePoint.SPSite siteColl = new SPSite(RootSiteCollection);
            StringBuilder sbFields = new StringBuilder();
            StringBuilder sbVals = new StringBuilder();

            StreamWriter sw = null;

            foreach (SPWeb web in siteColl.AllWebs)
            {
                Console.WriteLine("Processing site "+web.Url);
                sbFields.Length = 0;
                

                foreach (SPList list in web.Lists)
                {
                    Console.WriteLine("Processing list " + list.ID);
                    sbVals.Length = 0;
                    if (list.BaseType == SPBaseType.DocumentLibrary && list.Hidden == false)
                    {
                        j = 0;
                        foreach (SPItem item in list.Items)
                        {
                            Console.WriteLine("Processing item " + item.ID);
                            if (j == 0)
                            {
                                sbFields.Append("SourcePath");
                                sbFields.Append(',');
                            }

                            sbVals.Append(item["URL Path"].ToString().Replace(',',' '));
                            sbVals.Append(',');

                            foreach (SPField field in item.Fields)
                            {
                                try
                                {
                                    if (field.Hidden == false && field.Sealed == false )
                                    {
                                        if (j == 0)
                                        {
                                            sbFields.Append(field.ToString());
                                            sbFields.Append(',');
                                        }

                                        if (!string.IsNullOrEmpty(item[field.ToString()].ToString()))
                                            sbVals.Append(item[field.ToString()].ToString().Replace(',', ' '));
                                        else
                                            sbVals.Append(" ");

                                        sbVals.Append(',');

                                    }
                                }
                                catch { }
                            }
                            //remove last ','
                            if (sbFields.Length > 0)
                                sbFields.Length = sbFields.Length - 1;
                            if (sbVals.Length > 0)
                                sbVals.Length = sbVals.Length - 1;
                            // add new lines
                            sbFields.Append(@"
"); sbVals.Append(@"
");
                            j++;

                        }
                    }
                        sbFields.Append(sbVals.ToString());
                        sbFields.Append(@"
");
                }

                sw = new StreamWriter(@"c:\metadata_" + web.Url.Substring(web.Url.LastIndexOf(@"/")+1) + @".csv");

                sw.Write(sbFields.ToString());
                sw.Write(sbVals.ToString());
                sw.Flush();
                sw.Close();

            }
        }
    }
}