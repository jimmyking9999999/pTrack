script "pTrack";
notify Coolfood;

import <TimeTracking.ash>
import <ProfitTracking.ash>

boolean resetDailyTracking();
void addBreakpoint(string name);
void pBreakfast();
void compareBreakpoints(string bp1, string bp2);
void compare_using_list_and_date(string date);
void printBreakpointList();
void printBreakpointListComparison();
void printHelp();
void ptrackCheckUpdate();

int version = 2;
string[int] updates;
updates[0] = "Update Log Added";
updates[1] = "File compare added. Check your <font color=008080>KolMafia/data/Profit Tracking/"+my_name()+"/inventory</font> files and use them to compare across days!";
updates[2] = "Ptrack will now handle duplicate breakpoint names by giving the repeat a number.";

void printHelp() {
    print_html("<font color=eda800><b>ptrack Breakpoint Wrapper Commands</b></font>");
    print_html("<b>help</b> - Prints this help list.");
    print_html("<b>breakfast</b> - Sets a breakpoint named <b><font color=eda800>start</font></b> and then runs breakfast to track breakfast profits.");
    print_html("<b>add (bp name)</b> - Adds a breakpoint name. Names must be unique and contain no spaces.");
    print_html("<b>compare (bp1 name) (bp2 name)</b> - Compares two breakpoints.");
    print_html("<b>dcompare (bp1 name) (bp2 name)</b> - Descriptive Compare. Lists your top 10 item loss and profits.");
    print_html("<b>list</b> - List today's breakpoints.");
    print_html("<b>recap</b> - Recaps all breakpoints and their differences as well as your first and last breakpoints.");
    print_html("<b>coinvalue</b> - Examines all coinmaster currencies and attempts to value them.");
    print_html("<b>fileCompare (date1) (bp1) (date2) (bp2)</b> - Go into your <font color=008080>KolMafia/data/Profit Tracking/"+my_name()+"/inventory</font> files and find two breakpoints you would like to compare. File format is as follows: <font color=008080>date breakpoint.txt</font>. Do not include the .txt!");
    
    ptrackCheckUpdate();
}

void ptrackCheckUpdate() {
    //initialize
    if (get_property("prusias_profitTracking_scriptVersion") == "")
        set_property("prusias_profitTracking_scriptVersion", "-1");
    //print updates
    if (get_property("prusias_profitTracking_scriptVersion").to_int() != version) {
        print_html("<font color=eda800><b>----pTrack's latest updates----</b></font>");
        int lastUpdated = get_property("prusias_profitTracking_scriptVersion").to_int();
        for i from (lastUpdated+1) to (version) {
            print_html(i + " <font color=eda800>-</font> " + updates[i]);
        }
        print_html("<font color=eda800>---------------</font>");
        set_property("prusias_profitTracking_scriptVersion", version);
    }
}

boolean resetDailyTracking() {
    string today = today_to_string();
    string prev_prop = get_property("prusias_profitTracking_date");
    if (today != prev_prop) {
        set_property("prusias_profitTracking_date", today);
        clear_event_list();
        return true;
    } else {
        return false;
    }
}

void addBreakpoint(string name) {
    resetDailyTracking();
    string[int] split_map = split_string(get_property("thoth19_event_list"), ",");
    int last = count(split_map) -1;
	if (last >= 1) {
		for it from 0 to last {
            if (split_map[it] == name) {
                addBreakpoint(name + "1");
                return;
            }
        }
	}
    log_both_and_add(name);
}

void compareBreakpoints(string bp1, string bp2) {
    string date = get_property("prusias_profitTracking_date");
    compare_both(date, bp1, date, bp2, true);
}

void expressiveCompareBreakpoints(string bp1, string bp2) {
    string date = get_property("prusias_profitTracking_date");
    compare_both(date, bp1, date, bp2, false);
}

void pBreakfast() {
    if (resetDailyTracking()) {
        addBreakpoint("start");
    }
    cli_execute("breakfast");
}

void printBreakpointList() {
    string date = get_property("prusias_profitTracking_date");
    if (get_property("thoth19_event_list") == "") {
        print_html("<b>No Breakpoints found on " + date + "</b>");
        return;
    }
    string[int] split_map = split_string(get_property("thoth19_event_list"), ",");
    print_html("<b>Breakpoints saved for " + date + "</b>");
    foreach it in split_map {
        print("- " + split_map[it]);
    }
}

void printBreakpointListComparison() {
    string date = get_property("prusias_profitTracking_date");
    if (get_property("thoth19_event_list") == "") {
        print_html("<b>No Breakpoints found on " + date + "</b>");
        return;
    }
    string[int] split_map = split_string(get_property("thoth19_event_list"), ",");
    if (count(split_map) <2) {
        print_html("<b>Not enough Breakpoints found on " + date + "</b>");
        return;
    }
    print_html("<font color=0000ff><b>Now comparing all of " + date + "'s Breakpoints...</b></font>");
    compare_using_list_and_date(date);
    print_html("<font color=0000ff><b>Comparing your First and Last Breakpoints</b></font>");
    int last = count(split_map) - 1;
    compare_both(date, split_map[0], date, split_map[last], false);
    print_html("<font color=eda800><b>Thank you for using ptrack breakpoints wrapper</b></font>");
    ptrackCheckUpdate();
}

void compare_using_list_and_date(string date) {
	string[int] split_map = split_string(get_property("thoth19_event_list"), ",");
	string event1 = split_map[0];
	string event2;
	int last = count(split_map) -1;
	if (last < 1) {
		print("Not enough breakpoints in list");
		return;
	}
	for it from 1 to last {
	   event2 = split_map[it];
	   print_html("<b>Now comparing " + event1 + " and " + event2 + "</b>");
	   compare_both(date, event1, date, event2);
	   event1 = event2;
	}
}



void main(string option) {
    string [int] commands = option.split_string("\\s+");
    for(int i = 0; i < commands.count(); ++i){
        switch(commands[i]){
            case "add":
                if(i + 1 < commands.count())
                {
                    i+=1;
                    addBreakpoint(commands[i]);
                } else {
                    print("Please provide a breakpoint name", "red");
                }
                return;
            case "breakfast":
                pBreakfast();
                return;
            case "compare":
                if(i + 2 < commands.count())
                {
                    compareBreakpoints(commands[i+1], commands[i+2]);
                } else {
                    print("Please provide two valid breakpoint names", "red");
                }
                return;
            case "dCompare":
            case "dcompare":
                if(i + 2 < commands.count())
                {
                    expressiveCompareBreakpoints(commands[i+1], commands[i+2]);
                } else {
                    print("Please provide two valid breakpoint names", "red");
                }
                return;
            case "filecompare":
            case "fileCompare":
                if(i + 4 < commands.count())
                {
                    compare_both(commands[i+1], commands[i+2], commands[i+3], commands[i+4], false);
                } else {
                    print("Please provide the following arguments: date1, breakpoint1, date2, breakpoint2", "red");
                }
                return;
            case "coinValue":
            case "coinvalue":
                cli_execute("coinvalue");
                return;
            case "list":
                printBreakpointList();
                return;
            case "recap":
                printBreakpointListComparison();
                return;
            case "help":
                printHelp();
                return;
            default:
                printHelp();
                return;
        }
    }
}
