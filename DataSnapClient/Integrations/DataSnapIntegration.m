#import "DataSnapIntegration.h"
#import "GlobalUtilities.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (AddNotNil)

- (void)addNotNilEntriesFromDictionary:(NSDictionary *)otherDictionary {
    if(otherDictionary) {
        [self addEntriesFromDictionary:otherDictionary];
    }
}

@end

@implementation DataSnapIntegration

+ (NSArray *)getBeaconKeys {
    return @[@"id",
             @"ble_uuid",
             @"ble_vender_uuid",
             @"blue_vender_id",
             @"rssi",
             @"previous_rssi",
             @"name",
             @"latitude",
             @"longitude",
             @"organization_ids",
             @"visibility",
             @"battery_level",
             @"hardware",
             @"categories",
             @"tags"];
}

+ (NSArray *)getUserIdentificationKeys {
    return @[@"mobile_device_bluetooth_identifier",
             @"mobile_device_ios_idfa",
             @"mobile_device_ios_openidfa",
             @"mobile_device_ios_idfv",
             @"mobile_device_ios_udid",
             @"datasnap_uuid",
             @"web_domain_userid",
             @"web_cookie",
             @"domain_sessionid",
             @"web_network_userid",
             @"web_user_fingerprint",
             @"web_analytics_company_z_cookie",
             @"global_distinct_id",
             @"global_user_ipaddress",
             @"mobile_device_fingerprint",
             @"facebook_uid",
             @"mobile_device_google_advertising_id",
             @"mobile_device_google_google_advertising_id_opt_in"];
}

+ (NSArray *)getDataSnapDeviceKeys {
    return @[@"user_agent",
             @"ip_address",
             @"platform",
             @"os_version",
             @"model",
             @"manufacturer",
             @"name",
             @"vender_id"];
}

+ (NSDictionary *)locationEvent:(NSObject *)obj details:(NSDictionary *)details { return @{}; }

// map dictionaries keys using withWith:map
+ (NSDictionary *)map:(NSDictionary *)dictionary withMap:(NSDictionary *)map {
    
    NSMutableDictionary *mapped = [[NSMutableDictionary alloc] initWithDictionary:dictionary];

    for (NSString *key in map) {
        if ( map[key] ) {
            mapped[map[key]] = mapped[key];
            [mapped removeObjectForKey:key];
        }
    }
    
    return mapped;
}

// return dictionary of an objects properties
+ (NSDictionary *)dictionaryRepresentation:(NSObject *)obj {
    
    unsigned int count = 0;
    // Get a list of all properties in the class.
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        NSString *value = [obj valueForKey:key];
        
        // Only add to the NSDictionary if it's not nil.
        if (value)
            [dictionary setObject:value forKey:key];
    }
    
    return dictionary;
}


+ (NSDictionary *)getUserAndDataSnapDictionary {
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:[GlobalUtilities getSystemData]];
    [data addNotNilEntriesFromDictionary:[GlobalUtilities getCarrierData]];
    [data addNotNilEntriesFromDictionary:[GlobalUtilities getIPAddress]];
    
    NSMutableDictionary *returnDictionary = [NSMutableDictionary new];
    returnDictionary[@"datasnap"] = [NSMutableDictionary new];
    returnDictionary[@"datasnap"][@"device"] = [NSMutableDictionary new];
    returnDictionary[@"user"] = [NSMutableDictionary new];
    returnDictionary[@"user"][@"id"] = [NSMutableDictionary new];
    returnDictionary[@"custom"] = [NSMutableDictionary new];
    
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([[self getDataSnapDeviceKeys] containsObject:key]) {
            returnDictionary[@"datasnap"][@"device"][key] = data[key];
        } else if ([[self getUserIdentificationKeys] containsObject:key]) {
            returnDictionary[@"user"][@"id"][key] = data[key];
        } else {
            returnDictionary[@"custom"][key] = data[key];
        }
    }];
    
    NSDictionary *carrierData = [GlobalUtilities getCarrierData];
    [returnDictionary[@"datasnap"][@"device"] addNotNilEntriesFromDictionary:carrierData];
    
    return returnDictionary;
}

@end

