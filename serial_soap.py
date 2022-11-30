import serial
import csv
import datetime

serialPort = serial.Serial(port="COM8", baudrate=115200, parity= serial.PARITY_EVEN, stopbits=serial.STOPBITS_TWO, bytesize=serial.SEVENBITS)

while True :
    file = "BancoDados.csv"
    all_data = []
    with open(file, newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        for row in reader:
            all_data.append(row)

    serialString = serialPort.read_until("#".encode("ascii"))
    cleaned_string = str(serialString.decode("utf-8")[:3])

    id = cleaned_string[0]
    height = cleaned_string[1:]
    now = str(datetime.datetime.now()).split(".")[0]
    new_data = [id, height, now]
    all_data.append(new_data)

    with open(file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=',')
        for row in all_data:
            writer.writerow(row)