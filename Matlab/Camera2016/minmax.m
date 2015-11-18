function mm = minmax(struc)
mm = [min(min(struc.x)) min(min(struc.y)) min(min(struc.z))
      max(max(struc.x)) max(max(struc.y)) max(max(struc.z))];