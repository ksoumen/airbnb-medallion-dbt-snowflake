{% set configs = [
    {
        "table" : "AIRBNB.silver.silver_BOOKINGS",
        "columns" : "silver_bookings.*",
        "alias" : "silver_bookings"
    },
     {
        "table" : "AIRBNB.silver.silver_LISTINGS",
        "columns" : "silver_listings.host_id, silver_listings.property_type, silver_listings.room_type, silver_listings.city, silver_listings.country, silver_listings.accommodates,silver_listings.bedrooms, silver_listings.bathrooms, silver_listings.price_per_night,silver_listings.price_per_night_tag, silver_listings.created_at as listings_created_at",
        "alias" : "silver_listings",
        "join_condition" : "silver_bookings.listing_id = silver_listings.listing_id"
    },
    {
        "table" : "AIRBNB.silver.silver_HOSTS",
        "columns" : "silver_hosts.host_name, silver_hosts.host_since, silver_hosts.is_superhost, silver_hosts.response_rate,silver_hosts.response_rate_quality, silver_hosts.created_at as host_created_at",
        "alias" : "silver_hosts",
        "join_condition" : "silver_listings.host_id = silver_hosts.host_id"
    }
   
]%}

SELECT
    {% for config in configs %}
        {{config['columns']}}{% if not loop.last %}, {% endif %}
    {% endfor %}
FROM
    {% for config in configs %}
    {% if loop.first %}
        {{config['table']}} AS {{config['alias']}}
    {% else %}
        LEFT JOIN {{config['table']}} AS {{config['alias']}}
        ON {{config['join_condition']}}
        {% endif %}
        {% endfor %}