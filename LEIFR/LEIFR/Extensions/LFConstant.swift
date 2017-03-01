//
//  LFConstant.swift
//  LEIFR
//
//  Created by Lei Mingyu on 12/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Foundation

struct Color {
    static let iron = UIColor.eightBitColor(red: 74, green: 75, blue: 72, alpha: 1)
	static let limeCyan = UIColor(red:191/255, green:212/255, blue:209/255, alpha:1.00)
}

struct LFNotification {
	static let databaseReconstructionProgress = "LFNotification.databaseReconstructionProgress"
	static let databaseReconstructionComplete = "LFNotification.databaseReconstructionComplete"
}

struct CountryCode {
	static func allCountries() -> [[String]] {
		return [["SA", "ARG"], ["SA", "BOL"], ["SA", "BRA"], ["SA", "CHL"], ["SA", "COL"], ["SA", "ECU"], ["SA", "FLK"], ["SA", "GUF"], ["SA", "GUY"], ["SA", "PRY"], ["SA", "PER"], ["SA", "SUR"], ["SA", "URY"], ["SA", "VEN"], ["OC", "ASM"], ["OC", "AUS"], ["OC", "SLB"], ["OC", "COK"], ["OC", "FJI"], ["OC", "PYF"], ["OC", "KIR"], ["OC", "GUM"], ["OC", "NRU"], ["OC", "NCL"], ["OC", "VUT"], ["OC", "NZL"], ["OC", "NIU"], ["OC", "NFK"], ["OC", "MNP"], ["OC", "UMI"], ["OC", "FSM"], ["OC", "MHL"], ["OC", "PLW"], ["OC", "PNG"], ["OC", "PCN"], ["OC", "TKL"], ["OC", "TON"], ["OC", "TUV"], ["OC", "WLF"], ["OC", "WSM"], ["NA", "ATG"], ["NA", "BHS"], ["NA", "BRB"], ["NA", "BMU"], ["NA", "BLZ"], ["NA", "VGB"], ["NA", "CAN"], ["NA", "CYM"], ["NA", "CRI"], ["NA", "CUB"], ["NA", "DMA"], ["NA", "DOM"], ["NA", "SLV"], ["NA", "GRL"], ["NA", "GRD"], ["NA", "GLP"], ["NA", "GTM"], ["NA", "HTI"], ["NA", "HND"], ["NA", "JAM"], ["NA", "MTQ"], ["NA", "MEX"], ["NA", "MSR"], ["NA", "ANT"], ["NA", "CUW"], ["NA", "ABW"], ["NA", "SXM"], ["NA", "BES"], ["NA", "NIC"], ["NA", "UMI"], ["NA", "PAN"], ["NA", "PRI"], ["NA", "BLM"], ["NA", "KNA"], ["NA", "AIA"], ["NA", "LCA"], ["NA", "MAF"], ["NA", "SPM"], ["NA", "VCT"], ["NA", "TTO"], ["NA", "TCA"], ["NA", "USA"], ["NA", "VIR"], ["EU", "ALB"], ["EU", "AND"], ["EU", "AZE"], ["EU", "AUT"], ["EU", "ARM"], ["EU", "BEL"], ["EU", "BIH"], ["EU", "BGR"], ["EU", "BLR"], ["EU", "HRV"], ["EU", "CYP"], ["EU", "CZE"], ["EU", "DNK"], ["EU", "EST"], ["EU", "FRO"], ["EU", "FIN"], ["EU", "ALA"], ["EU", "FRA"], ["EU", "GEO"], ["EU", "DEU"], ["EU", "GIB"], ["EU", "GRC"], ["EU", "VAT"], ["EU", "HUN"], ["EU", "ISL"], ["EU", "IRL"], ["EU", "ITA"], ["EU", "KAZ"], ["EU", "LVA"], ["EU", "LIE"], ["EU", "LTU"], ["EU", "LUX"], ["EU", "MLT"], ["EU", "MCO"], ["EU", "MDA"], ["EU", "MNE"], ["EU", "NLD"], ["EU", "NOR"], ["EU", "POL"], ["EU", "PRT"], ["EU", "ROU"], ["EU", "RUS"], ["EU", "SMR"], ["EU", "SRB"], ["EU", "SVK"], ["EU", "SVN"], ["EU", "ESP"], ["EU", "SJM"], ["EU", "SWE"], ["EU", "CHE"], ["EU", "TUR"], ["EU", "UKR"], ["EU", "MKD"], ["EU", "GBR"], ["EU", "GGY"], ["EU", "JEY"], ["EU", "IMN"], ["AS", "AFG"], ["AS", "AZE"], ["AS", "BHR"], ["AS", "BGD"], ["AS", "ARM"], ["AS", "BTN"], ["AS", "IOT"], ["AS", "BRN"], ["AS", "MMR"], ["AS", "KHM"], ["AS", "LKA"], ["AS", "CHN"], ["AS", "TWN"], ["AS", "CXR"], ["AS", "CCK"], ["AS", "CYP"], ["AS", "GEO"], ["AS", "PSE"], ["AS", "HKG"], ["AS", "IND"], ["AS", "IDN"], ["AS", "IRN"], ["AS", "IRQ"], ["AS", "ISR"], ["AS", "JPN"], ["AS", "KAZ"], ["AS", "JOR"], ["AS", "PRK"], ["AS", "KOR"], ["AS", "KWT"], ["AS", "KGZ"], ["AS", "LAO"], ["AS", "LBN"], ["AS", "MAC"], ["AS", "MYS"], ["AS", "MDV"], ["AS", "MNG"], ["AS", "OMN"], ["AS", "NPL"], ["AS", "PAK"], ["AS", "PHL"], ["AS", "TLS"], ["AS", "QAT"], ["AS", "RUS"], ["AS", "SAU"], ["AS", "SGP"], ["AS", "VNM"], ["AS", "SYR"], ["AS", "TJK"], ["AS", "THA"], ["AS", "ARE"], ["AS", "TUR"], ["AS", "TKM"], ["AS", "UZB"], ["AS", "YEM"], ["AN", "ATA"], ["AN", "BVT"], ["AN", "SGS"], ["AN", "ATF"], ["AN", "HMD"], ["AF", "DZA"], ["AF", "AGO"], ["AF", "BWA"], ["AF", "BDI"], ["AF", "CMR"], ["AF", "CPV"], ["AF", "CAF"], ["AF", "TCD"], ["AF", "COM"], ["AF", "MYT"], ["AF", "COG"], ["AF", "COD"], ["AF", "BEN"], ["AF", "GNQ"], ["AF", "ETH"], ["AF", "ERI"], ["AF", "DJI"], ["AF", "GAB"], ["AF", "GMB"], ["AF", "GHA"], ["AF", "GIN"], ["AF", "CIV"], ["AF", "KEN"], ["AF", "LSO"], ["AF", "LBR"], ["AF", "LBY"], ["AF", "MDG"], ["AF", "MWI"], ["AF", "MLI"], ["AF", "MRT"], ["AF", "MUS"], ["AF", "MAR"], ["AF", "MOZ"], ["AF", "NAM"], ["AF", "NER"], ["AF", "NGA"], ["AF", "GNB"], ["AF", "REU"], ["AF", "RWA"], ["AF", "SHN"], ["AF", "STP"], ["AF", "SEN"], ["AF", "SYC"], ["AF", "SLE"], ["AF", "SOM"], ["AF", "ZAF"], ["AF", "ZWE"], ["AF", "SSD"], ["AF", "ESH"], ["AF", "SDN"], ["AF", "SWZ"], ["AF", "TGO"], ["AF", "TUN"], ["AF", "UGA"], ["AF", "EGY"], ["AF", "TZA"], ["AF", "BFA"], ["AF", "ZMB"]];
	}
}
