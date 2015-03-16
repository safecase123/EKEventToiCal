//
//  Category.m
//  EKEventToiCal
//
//  Created by Dan Willoughby on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EKEvent+Utilities.h"
@implementation EKEvent (Utilities)

-(NSString *) genRandStringLength
{
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    int len = 36;
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex:(rand() % [letters length])]];
        
    }
    
    NSString *c = [randomString substringWithRange:NSMakeRange(0, 8)];
    NSString *d = [randomString substringWithRange:NSMakeRange(8, 4)];
    NSString *e = [randomString substringWithRange:NSMakeRange(12, 4)];
    NSString *f = [randomString substringWithRange:NSMakeRange(16, 4)];
    NSString *g = [randomString substringWithRange:NSMakeRange(20, 12)];
    
    NSMutableString *stringWithDashes = [NSMutableString string];
    
    [stringWithDashes appendFormat:@"%@-%@-%@-%@-%@",c,d,e,f,g];
    
    return stringWithDashes;
}

- (NSString *)iCalString
{
    NSMutableString *iCalString = [NSMutableString string];
    
    //The first line must be "BEGIN:VCALENDAR"
    [iCalString appendString:@"BEGIN:VCALENDAR"];
    [iCalString appendString:@"\rVERSION:2.0"];
    
    //calendar
    
    if (self.calendar.title) {
        //[iCalString appendFormat:@"\rX-WR-CALNAME:%@",self.calendar.title];
    }
    
    //  CGColorRef blah = self.calendar.CGColor;
    // NSLog(@"********************* = %@",blah);
    
    //X-WR-CALNAME:Untitled 2 -----calendar's Title ical
    //X-APPLE-CALENDAR-COLOR:#F57802 -----calendar color ical
    
    //Event Start Date
    [iCalString appendString:@"\rBEGIN:VEVENT"];
    
    //allDay
    if (self.allDay) {
        
        NSDateFormatter *format1 = [NSDateFormatter new];
        [format1 setDateFormat:@"yyyyMMdd"];
        NSString *allDayDate = [format1 stringFromDate:self.startDate];
        
        [iCalString appendFormat:@"\rDTSTART;VALUE=DATE:%@",allDayDate];
        
        //get startdate and add 1 day for the end date.
        NSDate *addDay = [self.startDate dateByAddingTimeInterval:86400];
        NSString *allDayEnd = [format1 stringFromDate:addDay];
        
        [iCalString appendFormat:@"\rDTEND;VALUE=DATE:%@",allDayEnd];
    }
    else
    {
        if (self.startDate && self.endDate)
        {
            [iCalString appendString:@"\rDTSTART;TZID=Asia/Kolkata:"];
            
            NSDateFormatter *format2 = [NSDateFormatter new];
            [format2 setDateFormat:@"yyyyMMdd'T'HHmmss"];
            
            NSString *dateAsString = [format2 stringFromDate:self.startDate];
            [iCalString appendString:dateAsString];
            //end date
            
            [iCalString appendString:@"\rDTEND;TZID=Asia/Kolkata:"];
            
            NSString *dateAsString1 = [format2 stringFromDate:self.endDate];
            
            [iCalString appendString:dateAsString1];
            
        }
        else {
            NSLog(@"****Error****Missing one of needed values: startDate or endDate");
        }
    }
    
    [iCalString appendString:@"\rDTSTAMP:"];    //date the event was created
    NSDateFormatter *format3 = [NSDateFormatter new];
    [format3 setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    
    NSString *dateAsString2 = [format3 stringFromDate:self.lastModifiedDate];
    [iCalString appendString:dateAsString2];
    
    //lastModifiedDate
    if (self.lastModifiedDate) {
        
        [iCalString appendString:@"\rLAST-MODIFIED:"];
        
        NSString *dateAsString2 = [format3 stringFromDate:self.lastModifiedDate];
        [iCalString appendString:dateAsString2];
        
    }
    
    //UID is generated randomly
    NSString *a = [self genRandStringLength];
    [iCalString appendFormat:@"\rUID:%@0000000000000000000",a];
    
    //attendees @TODO: The property is read-only and cannot be modified so this is not complete or tested
    
    for (EKParticipant *attend in self.attendees) {
        [iCalString appendString:@"\rATTENDEE"];
        if (attend.name) {
            [iCalString appendFormat:@";CN=%@",attend.name];
        }
        //@TODO:this is not complete
        if (attend.participantStatus) {
            [iCalString appendFormat:@";PARTSTAT=%u",attend.participantStatus];
        }
        //@TODO:this is not complete
        if (attend.participantType) {
            
            [iCalString appendFormat:@";CUTYPE=%u",attend.participantType];
        }
        //@TODO:this is not complete
        if (attend.participantRole) {
            [iCalString appendFormat:@";ROLE=%u",attend.participantRole];
        }
    }
    
    //ATTENDEE;CN="Dan Willoughby";CUTYPE=INDIVIDUAL;PARTSTAT=ACCEPTED:mailto:email
    //availability @TODO:    The property is read-only and cannot be modified so this is not complete or tested
    
    if (self.availability == 1) {
        [iCalString appendString:@"\rTRANSP:OPAQUE"];    //busy
    }
    else {
        [iCalString appendString:@"\rTRANSP:TRANSPARENT"];    //free
    }
    NSLog(@" %d",self.availability);
    //eventIdentifier @TODO: The property is read-only and cannot be modified so this is not complete or tested
    
    //isDetached @TODO: The property is read-only and cannot be modified so this is not complete or tested
    
    //location
    if (self.location) {
        [iCalString appendFormat:@"\rLOCATION:%@",self.location];
    }
    
    //organizer @TODO: The property is read-only and cannot be modified so this is not complete or tested
    if  (self.organizer != nil) {
        [iCalString appendString:@"\rORGANIZER"];
        if (self.organizer.name) {
            [iCalString appendFormat:@";CN=%@",self.organizer.name];
        }
        //this is not complete
        if (self.organizer.participantStatus) {
            [iCalString appendFormat:@";PARTSTAT=%u",self.organizer.participantStatus];
            
        }
        //this is not complete
        if (self.organizer.participantType) {
            [iCalString appendFormat:@";CUTYPE=%u",self.organizer.participantType];
            
        }
        //this is not complete
        if (self.organizer.participantRole) {
            [iCalString appendFormat:@";ROLE=%u",self.organizer.participantRole];
            
        }
    }
    
    //recurrenceRule
    NSString *recurrenceString = [NSString stringWithFormat:@"%@", self.recurrenceRules];
    NSArray *partsArray = [recurrenceString componentsSeparatedByString:@"RRULE "];
    
    if ([partsArray count] > 1) {
        NSString *secondHalf = [partsArray objectAtIndex:1];
        secondHalf = [secondHalf stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        secondHalf = [secondHalf stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        secondHalf = [secondHalf stringByReplacingOccurrencesOfString:@")" withString:@""];
        
        [iCalString appendFormat:@"\rRRULE:%@",secondHalf];
    }
    
    //When a calendar component is created, its sequence number is zero
    [iCalString appendString:@"\rSEQUENCE:0"];
    
    //status
    if (self.status == 1) {
        [iCalString appendString:@"\rSTATUS:CONFIRMED"];
    }
    if (self.status == 2) {
        [iCalString appendString:@"\rSTATUS:TENTATIVE"];
    }
    if (self.status == 3) {
        [iCalString appendString:@"\rSTATUS:CANCELLED"];
    }
    
    //Event Title
    if (self.title) {
        [iCalString appendFormat:@"\rSUMMARY:%@",self.title];
    }
    
    //Notes
    if (self.notes) {
        [iCalString appendFormat:@"\rDESCRIPTION:%@",self.notes];
    }
    
    //Alarm
    for (EKAlarm *alarm in self.alarms) {
        [iCalString appendString:@"\rBEGIN:VALARM"];
        [iCalString appendString:@"\rACTION:DISPLAY"];//a message(usually the title of the event) will be displayed
        [iCalString appendString:@"\rDESCRIPTION:event reminder"]; //notes with the alarm--not the message.
        
        if (alarm.absoluteDate) {
            
            NSDateFormatter *format3 = [NSDateFormatter new];
            [format3 setDateFormat:@"yyyyMMdd'T'HHmmss"];
            
            NSString *dateAsString3 = [format3 stringFromDate:alarm.absoluteDate];
            
            [iCalString appendFormat:@"\rTRIGGER;VALUE=DATE-TIME:%@",dateAsString3];
            
        }
        if (alarm.relativeOffset) {
            
            //converts offset to D H M S then appends it to iCalString
            NSInteger offset = alarm.relativeOffset;
            int i = (int)offset - 1;
            
            int day = i / (24*60*60);
            i = i % (24*60*60);
            
            int hour = i / (60*60);
            i = i % (60*60);
            
            int minute = i / 60;
            i = i % 60;
            
            int second = i;
            
            [iCalString appendFormat:@"\rTRIGGER:-P"];
            
            if (day != 0) {
                
                [iCalString appendFormat:@"%dD", day];
                
            }
            if (hour || minute || second != 0) {
                [iCalString appendString:@"T"];
                
                if (hour != 0) {
                    
                    [iCalString appendFormat:@"%dH", hour];
                    
                }
                if (minute != 0) {
                    
                    [iCalString appendFormat:@"%dM", minute];
                    
                }
                if (second != 0) {
                    
                    [iCalString appendFormat:@"%dS", second];
                    
                }
            }
        }
        NSString *b = [self genRandStringLength];
        
        [iCalString appendFormat:@"\rX-WR-ALARMUID:%@",b];
        
        [iCalString appendString:@"\rEND:VALARM"];
        
    }
    
    [iCalString appendString:@"\rEND:VEVENT"];
    
    //The last line must be "END:VCALENDAR"
    [iCalString appendString:@"\rEND:VCALENDAR"];
    
    return [iCalString copy];
}

@end
