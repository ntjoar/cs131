from ports_config import min_port, max_port
# min_port and max_port are integers
import numpy as np
import pandas as pd
import random as rd

# https://stackoverflow.com/questions/312443/how-do-you-split-a-list-into-evenly-sized-chunks
def chunks(lst, n):
    """Yield successive n-sized chunks from lst."""
    for i in range(0, len(lst), n):
        yield lst[i:i + n]
def int2id(id_int, total_length=9):
    '''recover id number'''
    valid_digits = str(id_int)
    zeros = total_length - len(valid_digits)
    zeros_digits = "0" * zeros
    return zeros_digits + valid_digits


all_ports = list(range(min_port, max_port))
ports_each_student = 5
ports_slots = np.array(list(chunks(all_ports, ports_each_student)))
slots_idxs = list(range(ports_slots.shape[0]))

df = pd.read_csv("namelist.tab", sep="\t", header=None)
students_ids = [int2id(i) for i in df[0]]
num_students = len(students_ids)

selected_idxs = rd.sample(slots_idxs, k=num_students)
selected_ports = ports_slots[selected_idxs]
ports_info = [" ".join(tmp_ports.astype(str)) for tmp_ports in selected_ports]

data = {"student_id": students_ids, "ports": ports_info}
df_out = pd.DataFrame(data=data)
df_out.to_csv("ports_assigned.csv", index=None)