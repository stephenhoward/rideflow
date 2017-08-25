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

    set(k,v) {
        if ( this.definition()[k] ) {
            this.properties[k] = v;

            return this.properties[k];
        }
        return null;
    }

    get(k) {
        if ( this.definition()[k] ) {
            return this.properties[k];
        }
        return null;
    }

    save() {
        var defer = $.Deferred();
        $.post(this.url,JSON.stringify(this.properties)).done( (json) => {
            defer.resolve();
        });

        return defer.promise();
    }

    static load(id) {
        var defer = $.Deferred();
        $.getJSON(this.url + '/' + id).done( (json) => {
            defer.resolve( new this(json) );
        });

        return defer.promise();
    }

    static list() {
        var defer = $.Deferred();
        $.getJSON(this.url).done( (json) => {

            defer.resolve( json.map( (item) => {
                return new this(item);
            }) );
        });

        return defer.promise();
    }

}
