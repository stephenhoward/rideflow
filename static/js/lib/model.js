class Model {
    constructor(properties) {
        this.properties = {};
        for( let k of Object.keys(this.definition()) ) {
            if ( properties[k] ) {
                this.properties[k] = properties[k];
            }
        }
    }

    definition() {
        return {};
    }

    _set(k,v) {
        if ( k in this.definition() ) {
            this.properties[k] = v;

            return this.properties[k];
        }
        return null;
    }

    _get(k) {
        if ( k in this.definition() ) {
            return this.properties[k];
        }
        return null;
    }

    save(url) {
        var defer = $.Deferred();
        $.post(url,JSON.stringify(this.properties)).done( (json) => {
            for( let k of Object.keys(json) ) {
                this._set(k,json[k]);
            }
            defer.resolve(this);
        });

        return defer.promise();
    }

    static load(url) {
        var defer = $.Deferred();
        $.getJSON(url).done( (json) => {
            defer.resolve( new this(json) );
        });

        return defer.promise();
    }

    static list(url) {
        var defer = $.Deferred();
        $.getJSON(url).done( (json) => {

            defer.resolve( json.map( (item) => {
                return new this(item);
            }) );
        });

        return defer.promise();
    }

}
