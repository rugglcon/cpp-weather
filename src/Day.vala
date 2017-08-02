public class Day {
    private string weekday;
    private int64 high;
    private int64 low;
    private int64 humidity;
    private int precipitation;
    private string conditions;
    private int64 cur_temp;
    private bool is_today;
    private Hour[] times;
    private string deg_type;

    public Day (Json.Object info, bool today, string deg_type) {
        is_today = today;
        this.deg_type = deg_type;
        times = new Hour[24];

        if (is_today) {
            fill_today (info);
        }
    }

    public void fill_hour (Json.Object info) {
        if (is_today) {
            return;
        }
        var util = new WeatherUtil ();
        this.weekday = util.get_weekday (info);
        var this_hour = new DateTime.from_unix_utc (
                info.get_int_member ("dt")).get_hour ();
        if (times[this_hour] == null || 
                times[this_hour].get_day () != this.weekday) {
            times[this_hour] = new Hour (this_hour, this.deg_type);
        }

        var tmp_low = info.get_object_member ("main").
                        get_int_member ("temp_min");
        var tmp_high = info.get_object_member ("main").
                        get_int_member ("temp");

        times[this_hour].set_temp (tmp_high);
        this.high = (tmp_high > this.high ? tmp_high : this.high);
        this.low = (tmp_low < this.low ? tmp_low : this.low);

        var weather = info.get_array_member ("weather").
                get_element (0).get_object ();
        times[this_hour].set_cond (weather.get_string_member ("main"));
        times[this_hour].set_detail (weather.get_string_member ("description"));
    }

    private void fill_today (Json.Object info) {
        if (!is_today) {
            return;
        }
        var util = new WeatherUtil ();
        this.weekday = util.get_weekday (info);
        var tmp = info.get_array_member ("weather");
        var weather = tmp.get_element (0).get_object ();
        this.conditions = weather.get_string_member ("main");
        var main = info.get_object_member ("main");
        this.humidity = main.get_int_member ("humidity");
        this.high = main.get_int_member ("temp_max");
        this.low = main.get_int_member ("temp_min");
        this.cur_temp = main.get_int_member ("temp");
    }

    public bool is_full() {
        return (times[times.length - 1] != null ? true : false);
    }

    public string get_day () {
        return this.weekday;
    }

    public int64 get_high () {
        var util = new WeatherUtil ();
        if (deg_type == "C") {
            return util.get_celcius (this.high);
        } else {
            return util.get_fahrenheit (this.high);
        }
    }

    public int64 get_low () {
        var util = new WeatherUtil ();
        if (deg_type == "C") {
            return util.get_celcius (this.low);
        } else {
            return util.get_fahrenheit (this.low);
        }
    }

    public int64 get_humidity () {
        return this.humidity;
    }

    public int get_precipitation () {
        return this.precipitation;
    }

    public string get_conditions () {
        return this.conditions;
    }

    public Hour[] get_all_hours () {
        return this.times;
    }
}
