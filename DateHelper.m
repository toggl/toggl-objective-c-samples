
#import "DateHelper.h"
#import "ISO8601DateFormatter.h"

@implementation DateHelper

#pragma mark Convert datetime to date

+ (int) seconds_to_days:(long)seconds {
	return seconds / kSecondsPerDay;
}

+ (int) nsdate_to_days:(NSDate *)date {
	return [self seconds_to_days:[self nsdate_to_seconds:date]];
}

+ (NSString *) nsdate_to_date_string:(NSDate *)date {
	static NSDateFormatter *shortDateFormatter = nil;
	if (! shortDateFormatter) {
		shortDateFormatter = [[NSDateFormatter alloc] init];
		[shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
	}
	return [shortDateFormatter stringFromDate:date];
}

#pragma mark Formatting

+ (NSString *) format_date:(NSDate *)date {
	static NSDateFormatter *humanDateFormatter = nil;
	if (! humanDateFormatter) {
		humanDateFormatter = [[NSDateFormatter alloc] init];
		[humanDateFormatter setDateFormat:@"dd. MMM, EEE"];
	}
	return [humanDateFormatter stringFromDate:date];
}

+ (NSString *) format_seconds:(long)seconds with_seconds:(BOOL)with_seconds {

	int secs = seconds;
	int minutes = secs / 60;
	int hours = minutes / 60;
	
	minutes = minutes % 60;
	secs = secs % 60;

	if (with_seconds) {
		return [NSString stringWithFormat:@"%0.2d:%0.2d:%0.2d", hours, minutes, secs];
	} else {
		return [NSString stringWithFormat:@"%d:%0.2d h", hours, minutes];
	}
}

#pragma mark Convert timestamp to NSDate

+ (NSDate *) seconds_to_nsdate:(long) seconds {
	NSTimeInterval unix_timestamp = seconds;
	return [NSDate dateWithTimeIntervalSince1970: unix_timestamp];
}

#pragma mark Convert NSDate to GMT timestamp

+ (long) nsdate_to_seconds:(NSDate *)date {
	return [date timeIntervalSince1970];
}

#pragma mark Shortcuts

+ (long) current_timestamp_in_seconds {
	return [self nsdate_to_seconds:[NSDate date]];
}

+ (long) current_date_in_days {
	return [self seconds_to_days:[self current_timestamp_in_seconds]];
}

+ (long) current_timestamp_in_seconds_without_time_part {
	return [self current_date_in_days] * kSecondsPerDay;
}

+ (NSDate *) yesterday {
	return [self add_days:-1];
}

+ (NSDate *) tomorrow {
	return [self add_days:1];
}

+ (NSDate *) add_days:(int) days {
	double result = [self current_timestamp_in_seconds_without_time_part] + days * kSecondsPerDay;
	return [self seconds_to_nsdate:result];
}

#pragma mark ISO8601 formatting and parsing

+ (ISO8601DateFormatter *) dateFormatterISO8601 {
	static ISO8601DateFormatter* date_formatter_for_ISO8601 = nil;
	if (! date_formatter_for_ISO8601) {
		date_formatter_for_ISO8601 = [[ISO8601DateFormatter alloc] init];
		date_formatter_for_ISO8601.includeTime = YES;
	}
	return date_formatter_for_ISO8601;
}

+ (NSString *) nsdate_to_iso8601_string:(NSDate *)date {
    return [[self dateFormatterISO8601] stringFromDate:date];
}

+ (NSDate *) iso8601_string_to_nsdate:(NSString *)string {
	return [[self dateFormatterISO8601] dateFromString:string];
}

@end
