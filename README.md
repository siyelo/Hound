# Hound.cc

# Getting Started

## 
Ok so here's the deal
Lots of shizzle in here is run off resque, I found an awesome plugin called
resque scheduler (https://github.com/bvandenbos/resque-scheduler).
Read the documentation

I have it checking for new emails every minute.

To run this app, you actually need an instance of the scheduler running, so:

rake resque:scheduler

then you need to start your workers:

rake resque:work QUEUE='*'

and BAM. you're off to the racez.

Peace