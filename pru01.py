import pandas as pd
amazon_df = pd.DataFrame({ "department": ["HR", "IT", "HR", "Finance", "IT", "Finance"], "salary": [50000, 70000, 52000, 60000, 71000, 62000], "bonus": [1000, 2000, 2000, 0, 1000, 0] })
gxd=amazon_df.groupby("department")[["salary","bonus"]].mean()
print(gxd)