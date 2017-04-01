import sqlite3
conn = sqlite3.connect('doctor1.db')
c = conn.cursor()
c.execute('''CREATE TABLE doctor_times
             (location_id INTEGER,
             search_date TEXT, 
             doctor_id INTEGER,
             constrainta TEXT, 
            start_time TEXT, 
            current_time TEXT, 
            symbol TEXT,
            timestamp TEXT, 
            utc_offset_seconds INTEGER)''')

c.execute('''CREATE TABLE doctor
             (profession_id INTEGER,
             overall_rating REAL,
             bedside_manner REAL, 
            wait_time REAL, 
            doctor_id TEXT, 
            date TEXT, 
            gender TEXT, 
            symbol text, 
            main_specialty_id INTEGER,
            main_specialty_name TEXT,
            profile_url TEXT,
            total_reviews TEXT,
            location_ids TEXT,
            location_id INTEGER,
            address_1 TEXT,
            address_2 TEXT,
            address_3 TEXT,
            city TEXT,
            state TEXT,
            zip INTEGER,
            phone TEXT,
            latitude REAL,
            longitude REAL,
            utc_offset INT,
            utc_offset_seconds INT,
            is_in_network TEXT, 
            is_zocdoc TEXT,
            specialty_id INT, 
            procedureId INT, 
            insuranceCarrier INT,
            insurancePlan INT)''')

c.execute('''CREATE TABLE doctor_insurance
             (Doctor_Id INTEGER,
             Carrier_Name TEXT, 
             Plan_Name TEXT,
             AllProfessionals TEXT,
             AllLocations TEXT, 
            LocationsAccepting TEXT,
            ProfessionalsAccepting TEXT, 
            LocationCount INT, 
            Locations TEXT,
            ProfessionalCount INT, 
            Professionals TEXT)''')

c.close()
conn.close()