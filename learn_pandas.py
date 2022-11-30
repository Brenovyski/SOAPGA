import pandas as pd
import matplotlib.pyplot as plt

db = pd.read_csv("BancoDados.csv", parse_dates=True, index_col=2)
# teste = db[["Coluna", "Data"]]
db.plot()
plt.show()