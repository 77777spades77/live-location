from flask_sqlalchemy import SQLAlchemy
from flask_ngrok import run_with_ngrok
import datetime
from flask import Flask, render_template,request,jsonify
import random
import datetime
from pytz import timezone
import string
import pytz
from flask_cors import CORS, cross_origin

class Config(object):  
    DEBUG = False
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = 'this-really-needs-to-be-changed'
    SQLALCHEMY_DATABASE_URI = 'sqlite:////content/gdrive/MyDrive/image3.db'

class ProductionConfig(Config):
    DEBUG = False


class StagingConfig(Config):
    DEVELOPMENT = True
    DEBUG = True


class DevelopmentConfig(Config):
    DEVELOPMENT = True
    DEBUG = True


class TestingConfig(Config):
    TESTING = True


app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

app.config.from_object(Config)
db = SQLAlchemy(app)
run_with_ngrok(app)


class Shift(db.Model):
    __tablename__ = "shift"
    shift_key = db.Column(db.String, primary_key=True, unique=True)    
    userid = db.Column(db.String(128))#db.Column(db.String(),db.ForeignKey('User.username', ondelete="CASCADE"))
    day = db.Column(db.Date, unique=True) #Time(timezone=False)
    shift_type = db.Column(db.String(80))
    
    def __init__(self, shift_key ,userid, day, shift_type):
        self.shift_key = shift_key
        self.userid = userid
        self.day = day
        self.shift_type = shift_type

    def serialize(self):
        return {
            'shift_key' : self.shift_key,
            'shift_type': self.shift_type,
            'day': self.day,
            'userid': self.userid,
          }

def generate_key():
    return ''.join(random.choice(string.ascii_letters + string.digits)  for _ in range(50))

@app.route('/api/Shift-add', methods=['POST'])
def add_shift():
          json_data = request.form#get_json(force=True)
          print(type(json_data['day']))
          shift_key = generate_key()
          shift = Shift.query.filter_by(shift_key=shift_key).first()
          while shift:
              shift_key = generate_key()
              shift_key = Shift.query.filter_by(shift_key = shift_key).first()
          shift = Shift(            
            shift_key= shift_key, 
            shift_type = json_data['shift_type'],
            day = datetime.strptime(json_data['day'],'%Y-%m-%d'),
            userid = json_data['userid'],)
          db.session.add(shift)
          db.session.commit()
          result = Shift.serialize(shift)
          return {"status": 'success', 'data': result}, 200

@app.route('/api/shift-get', methods=['GET'])
def get_shift():
       result = []
       shifts = Shift.query.filter_by(userid = request.args.get('userid')).all()
       if shifts:
         for shift in shifts:
          result.append(Shift.serialize(shift))
         return {"status": 'success', 'data': result}, 200
       else:
         return {"status": "Shift Not Found"}, 404

@app.route('/api/shift-update', methods=['PATCH'])
def update_shift():
    json_data = request.form#get_json(force=True)
    shift = Shift.query.filter_by(shift_key = json_data['shift_key']).first()
    if shift:
          if (shift.shift_type != json_data['shift_type']):
              shift.shift_type = json_data['shift_type']
          db.session.commit()
          result = Shift.serialize(shift)
          return {"status": 'success', 'data': result}, 200
    else:
      return {"status": "Shift Not Found"}, 405    


class Leave(db.Model):
    __tablename__ = "leave"
    leave_key = db.Column(db.String, primary_key=True, unique=True)    
    userid = db.Column(db.String(128))#db.Column(db.String(),db.ForeignKey('User.username', ondelete="CASCADE"))
    reason = db.Column(db.String(80))
    date_range = db.Column(db.String(80) , default = '') 
    day = db.Column(db.String(80), default = '')
    time = db.Column(db.String(80), default = '')


 
    def __init__(self, leave_key,userid,time,day,date_range): 
        self.leave_key = leave_key,
        self.userid = userid
        self.time = time
        self.day = day
        self.date_range = date_range
 
    def serialize(self):
        
        return {
            'leave_key' : self.leave_key, 
            'userid': self.userid,
            'time':self.time,
            'day':self.day,
            'date_range': self.date_range
          }

def generate_key():
    return ''.join(random.choice(string.ascii_letters + string.digits)  for _ in range(50))

@app.route('/api/leave-add', methods=['POST'])
def add_leave():
          json_data = request.get_json(force=True)
          leave_key = generate_key()
          leave = Leave.query.filter_by(leave_key=leave_key).first()
          while leave:
              leave_key = generate_key()
              leave_key = Leave.query.filter_by(leave_key = leave_key).first()
          leave = Leave(            
            leave_key= leave_key, 
            userid = json_data['userid'],
            date_range = json_data['date_range'],
            time =  json_data['time'],
            day = json_data['day'])
          db.session.add(leave)
          db.session.commit()
          result = Leave.serialize(leave)
          return {"status": 'success', 'data': result}, 200

@app.route('/api/leave-get', methods=['GET'])
def get_leave():
       result = []
       leaves = Leave.query.filter_by(userid = request.args.get('userid')).all()
       if leaves:
         for leave in leaves:
            result.append(Leave.serialize(leave))
         return {"status": 'success', 'data': result}, 200
       else:
         return {"status": "Leave Not Found"}, 404


@app.route('/api/leave-delete', methods=['DELETE'])
def leave_delete():
        leave = Leave.query.filter_by(leave_key=request.args.get('leave_key')).first()
        if leave:
              db.session.delete(leave)
              db.session.commit()
              return {"status": 'success'}, 200
        else:
              return {"status": 'No leave found with that leave key'}, 404

class LiveLocation(db.Model):
    __tablename__ = "location"
    location_key = db.Column(db.String, primary_key=True, unique=True)
    userid = db.Column(db.String(128))#, ForeignKey("Employees.userId"))
    lat = db.Column(db.String(128))
    longi = db.Column(db.String(128))
    time_created = db.Column(db.DateTime(timezone=True), default = datetime.datetime.now(timezone('Asia/Kolkata')))

    def __init__(self, location_key, userid,lat ,longi):
        self.location_key = location_key 
        self.longi = longi
        self.userid = userid
        self.lat = lat
 
    def serialize(self):
        return {
            'location_key':self.location_key,
            'longi' : self.longi, 
            'userid': self.userid,
            'lat': self.lat,
            'time':self.time_created.isoformat()
          }

@app.route('/api/location-add', methods=['POST'])
def add_location():
          json_data = request.get_json(force=True)
          location_key = generate_key()
          location = LiveLocation.query.filter_by(location_key=location_key).first()
          while location:
              location_key = generate_key()
              location_key = LiveLocation.query.filter_by(location_key = location_key).first()
          location = LiveLocation(            
            location_key= location_key, 
            userid = json_data['userid'],
            lat = json_data['lat'],
            longi = json_data['longi'],
            )
          db.session.add(location)
          db.session.commit()
          result = LiveLocation.serialize(location)
          return {"status": 'success', 'data': result}, 200

@app.route('/api/location-get', methods=['GET'])
def get_location():
       result = []
       today = datetime.date.today()
       location = LiveLocation.query.filter(LiveLocation.userid == request.args.get('userid'),db.func.date(LiveLocation.time_created) == today).order_by(LiveLocation.time_created.desc()).all()#.filter_by(time_created = date.today())
       if location:
         for loc in location:
           result.append(LiveLocation.serialize(loc))
         print(result)
         return {"status": 'success', 'data': result}, 200
       else:
         return {"status": "Leave Not Found"}, 404


if __name__ == "__main__":
    with app.app_context():
      db.create_all()    
    app.run() # or setting host to '0.0.0.0'

