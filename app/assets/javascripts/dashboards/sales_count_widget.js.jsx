(function() {
    window.lo = window.lo || {};

    //require('chart.js')

    var sales_count_widget = React.createClass({
        propTypes: {
            totalOrderCount: React.PropTypes.number.isRequired,
            totalOrderCountGraph: React.PropTypes.object.isRequired
        },

        render: function () {
            var self = this;
            var labels=[], data_points=[];
            var j = this.props.totalOrderCountGraph
            if (j) {
                $.each(j, function (i,v)
                {
                    labels.push(i)
                    data_points.push(parseFloat(v))
                });
            }

            var data1 = {
                labels: labels,
                series: [
                    data_points
                ]
            };

            //var data1 = {
            //    labels: labels,
            //    datasets: [
            //        {
            //            label: "My First dataset",
            //            fillColor: "rgba(151,187,205,0.2)",
            //            strokeColor: "rgba(151,187,205,1)",
            //            pointColor: "rgba(151,187,205,1)",
            //            pointStrokeColor: "#fff",
            //            pointHighlightFill: "#fff",
            //            pointHighlightStroke: "rgba(151,187,205,1)",
            //            data: data_points
            //        }
            //    ]
            //};

            return (
                <div>
                    <div style={{fontSize: 36, textAlign: 'right'}}>
                        Total Count
                    </div>
                    <div style={{fontSize: 24, textAlign: 'right'}}>
                        {this.props.totalOrderCount}
                    </div>
                    <ChartistGraph data={data1} type={'Bar'}/>
                    <div style={{borderTop: '1px solid #EEE', padding: 3}}>
                        <span style={{textTransform: 'uppercase', fontSize: 12, fontWeight: 'bold'}}>View More ></span>
                    </div>
                </div>
            );
        }
    });

    window.lo.sales_count_widget = sales_count_widget;
    module.exports = sales_count_widget;

}).call(this);
