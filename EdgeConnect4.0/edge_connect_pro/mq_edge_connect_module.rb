require 'sketchup' unless Object.private_method_defined?(:file_loaded)

module MessizQinECPro
  class MQAttribute
    def self.initialize_line()
      mq_directory = File.dirname(__FILE__)
      mq_path = File.expand_path("mq_cache.txt", mq_directory)
      if File.read(mq_path).length == 0
        File.open(mq_path, "w") do |file|
          file.puts(1)
          file.puts(1)
          file.puts(0)
        end
      end
    end

    def self.clear_line()
      mq_directory = File.dirname(__FILE__)
      mq_path = File.expand_path("mq_cache.txt", mq_directory)
      File.open(mq_path, 'w') do |file|
        file.truncate(0)
      end
    end

    def self.replace_line(indices, arg)
      mq_directory = File.dirname(__FILE__)
      mq_path = File.expand_path("mq_cache.txt", mq_directory)
      initialize_line()
      lines = File.readlines(mq_path)
      lines[indices] = arg.to_s << $/
      File.open(mq_path, 'w') { |f| f.write(lines.join) }
    end

    def self.get_line(indices)
      mq_directory = File.dirname(__FILE__)
      mq_path = File.expand_path("mq_cache.txt", mq_directory)
      initialize_line()
      this_line = File.readlines(mq_path)[indices][0..-2]
      return this_line.to_f
    end
  end

  module MessizQinEdgeConnect
    class MQInstance
      def initialize
        @CROSS = Array.new
        @CURVE = Array.new

        @mq_all_connected = Array.new
        @mq_vertex = Array.new
      end

      def initialize_vertex(mq_vertex_a)
        @mq_vertex << mq_vertex_a if !@mq_vertex.include? mq_vertex_a
      end

      def new_edge(mq_edge_a)
        mq_edge_a.vertices.each do |ver|
          initialize_vertex(ver)
        end
      end

      def double_include(total_pair, single_pair)
        return true if total_pair.include?(single_pair) || total_pair.include?(single_pair.reverse)
      end

      def new_dotpair(mq_dotpair_a)
        if !double_include(@CURVE, mq_dotpair_a)
          @CURVE << mq_dotpair_a
          mq_dotpair_a.each do |dp|
            initialize_vertex(dp)
          end
        end
      end

      def concatenate(array)
        result = []
        array.each_with_index do |d, i|
          (i+2..array.length).each do |ind|
            result << [array[i], array[ind - 1]]
          end
        end
        return result
      end

      def connected_to_vertex(mq_all_connected_a)
        emp_arr = Array.new
        mq_all_connected_a.each do |ed|
          if ed.is_a? Sketchup::Edge
            ed.vertices.each do |ver|
              emp_arr << ver
            end
          end
        end
        ver_arr = Array.new
        emp_arr.each do |ver|
          ver_arr << ver if emp_arr.count(ver) == 1
        end
        return ver_arr
      end

      def new_all_connected(mq_all_connected_a)
        if !@mq_all_connected.include? mq_all_connected_a
          @mq_all_connected << mq_all_connected_a
          ver_arr = concatenate(connected_to_vertex(mq_all_connected_a))
          ver_arr.each do |ver_pair|
            if !double_include(@CROSS, ver_pair)
              @CROSS << ver_pair
              ver_pair.each do |ver|
                initialize_vertex(ver)
              end
            end
          end
        end
      end

      def get_curve; @CURVE; end
      def get_cross; @CROSS; end
      def get_vertex; @mq_vertex; end
    end


    class MQPoint3d
      def initialize()
        @mq_point3d = Array.new
      end

      def add_point3d(mq_point3d_a); @mq_point3d << mq_point3d_a; end

      def new_vertex(mq_vertex_a)
        add_point3d(mq_vertex_a.position)
      end

      def gain_point3d; @mq_point3d; end
    end

    class MQOrigin
      def self.new_origin(origin_p2d)
        instance = allocate
        origin_x, origin_y = p2d_to_xy(origin_p2d)
        instance.initialize_origin(origin_x, origin_y)
        instance
      end

      def self.p2d_to_xy(p2d)
        return p2d.to_a[0], p2d.to_a[1]
      end

      def initialize_origin(origin_x, origin_y)
        @origin_x = origin_x
        @origin_y = origin_y
      end

      def origin_x; @origin_x; end
      def origin_y; @origin_y; end
    end


    class MQBearing
      def inherited(child); end

      def self.new_p2d(it_p2d, mq_origin)
        instance = allocate
        it_x, it_y = p2d_to_xy(it_p2d)
        x = it_x - mq_origin.origin_x
        y = it_y - mq_origin.origin_y
        distance, phi = cartesian_to_bearing(x, y)
        instance.initialize_bearing(distance, phi)
        instance
      end

      def self.p2d_to_xy(p2d)
        return p2d.to_a[0], p2d.to_a[1]
      end

      def self.cartesian_to_bearing(x, y)
        distance = (x * x + y * y)**0.5
        radians = Math.atan(y / x.to_f)
        if (x > 0 && y > 0) || (x > 0 && y < 0) # quadrant 1 and 4
          phi = Math::PI / 2.0 - radians
        else # quadrant 2 and 3
          phi = 3 * Math::PI / 2.0 - radians
        end
        return distance, phi
      end

      def initialize_bearing(distance, phi)
        @distance = distance
        @phi = phi
      end

      def distance; @distance; end
      def phi; @phi; end

      def sort_by_distance(pol_arr)
        dis_arr = Array.new
        pol_arr.each do |pol|
          dis_arr << pol.distance
        end
        return dis_arr.index dis_arr.min
      end

      def sort_by_phi(pol_arr)
        phi_arr = Array.new
        pol_arr.each do |pol|
          phi_arr << pol.phi
        end
        return phi_arr.index phi_arr.min
      end
    end


    class MQVector < MQBearing
      attr_accessor :point3d_mq

      def initialize_mq_point3d
        @mq_point3d = Array.new
        @point3d_mq.each do |p3d|
          @mq_point3d << p3d
        end
      end

      def get_patten(p3d_xyz_arr)
        two_index = [0, 1, 2]
        p3d_xyz_arr.each_with_index do |arr, i|
          if arr.count(arr[0]) == arr.length
            two_index.delete(i)
          end
        end
        if two_index.length != 2
          UI.messagebox("Please select edges in the same plane")
          raise "Please select edges in the same plane"
        end
        return two_index
      end

      def initialize_mq_patten()
        x_arr = Array.new; y_arr = Array.new; z_arr = Array.new
        @mq_point3d.each do |p3d|
          p3d_arr = p3d.to_a
          x_arr << p3d_arr[0]
          y_arr << p3d_arr[1]
          z_arr << p3d_arr[2]
        end
        p3d_xyz_arr = [x_arr, y_arr, z_arr]
        @mq_patten = get_patten(p3d_xyz_arr)
      end

      def initialize_mq_point2d()
        @mq_point2d = Array.new()
        @mq_point3d.each do |p3d|
          @mq_point2d << Geom::Point2d.new(p3d.to_a[@mq_patten[0]], p3d.to_a[@mq_patten[1]])
        end
      end

      def dump_mq_point2d()
        @mq_point2d_copy = Array.new
        @mq_point2d.each do |p2d|
          @mq_point2d_copy << p2d
        end
      end

      def get_distance_nextone(one)
        @mq_point2d.delete(one)
        mq_origin = MQOrigin.new_origin(one)
        pol_arr = Array.new()
        @mq_point2d.each do |p2d|
          pol_arr << MQBearing.new_p2d(p2d, mq_origin)
        end
        nextone = @mq_point2d[sort_by_distance(pol_arr)]
        return nextone
      end

      def get_phi_nextone(one)
        @mq_point2d.delete(one)
        mq_origin = MQOrigin.new_origin(one)
        pol_arr = Array.new()
        @mq_point2d.each do |p2d|
          pol_arr << MQBearing.new_p2d(p2d, mq_origin)
        end
        nextone = @mq_point2d[sort_by_phi(pol_arr)]
        return nextone
      end

      def mirror(dog1, cat1, cat2)
        indices = Array.new
        cat2.each do |c2|
          indices << cat1.index(c2)
        end
        dog2 = Array.new
        indices.each do |ind|
          dog2 << dog1[ind]
        end
        return dog2
      end

      def random_start()
        return [@mq_point2d.sample]
      end

      def leftmost_v2d()
        phi_abs = Array.new
        @mq_point2d.each do |v2d|
          phi_abs << v2d.to_a[0]
        end
        indicate = phi_abs.index(phi_abs.min)
        return [@mq_point2d[indicate]]
      end

      def close_index(arr)
        ran = [0, 1].sample
        len = arr.length
        total_range = *(ran..len-1)
        if total_range.length % 2 != 0
          total_range.pop()
        end
        new_arr = Array.new()
        total_range.each_with_index do |ar, i|
          if i % 2 == 0
            new_arr << [arr[ar], arr[ar + 1]]
          end
        end
        return new_arr
      end

      def arrange_by_double_dis(ent)
        _line = Array.new()
        emp_arr = random_start()
        while @mq_point2d.length != 1
          nextone = get_distance_nextone(emp_arr[-1])
          emp_arr << nextone
        end
        final_mq = close_index(mirror(@mq_point3d, @mq_point2d_copy, emp_arr))
        final_mq.each do |pair|
          _line << ent.add_line(pair[0], pair[1])
        end
        return _line
      end

      def arrange_by_double_rad(ent)
        _line = Array.new()
        emp_arr = random_start()
        while @mq_point2d.length != 1
          nextone = get_phi_nextone(emp_arr[-1])
          emp_arr << nextone
        end
        final_mq = close_index(mirror(@mq_point3d, @mq_point2d_copy, emp_arr))
        final_mq.each do |pair|
          _line << ent.add_line(pair[0], pair[1])
        end
        return _line
      end

      def arrange_by_distance(ent)
        _line = Array.new()
        emp_arr = random_start()
        while @mq_point2d.length != 1
          nextone = get_distance_nextone(emp_arr[-1])
          emp_arr << nextone
        end
        final_mq = mirror(@mq_point3d, @mq_point2d_copy, emp_arr)
        _line << ent.add_line(final_mq[-1], final_mq[0])
        final_mq.each_with_index do |p3d, i|
          break if i == final_mq.length - 1
          _line << ent.add_line(p3d, final_mq[i+1])
        end
        return _line
      end

      def arrange_by_phi(ent)
        _line = Array.new()
        emp_arr = leftmost_v2d()
        while @mq_point2d.length != 1
          nextone = get_phi_nextone(emp_arr[-1])
          emp_arr << nextone
        end
        final_mq = mirror(@mq_point3d, @mq_point2d_copy, emp_arr)
        _line << ent.add_line(final_mq[-1], final_mq[0])
        final_mq.each_with_index do |p3d, i|
          break if i == final_mq.length - 1
          _line << ent.add_line(p3d, final_mq[i+1])
        end
        return _line
      end
    end

    class MQEdgeConnectApi
      def initialize(integer)
        @mode = integer
        @mod = Sketchup.active_model # Open model
        @ent = @mod.entities # All entities in model
        @sel = @mod.selection # Current selection
        if @sel.empty?
          UI.messagebox("Please select the elements you want to connect")
          raise "No Selection"
        end
        @cross = Array.new
        @curve = Array.new
        @edge = Array.new
        @counter = 1
        @sel_copy = Array.new
      end

      def add_edge(_s)
        if _s.is_a? Sketchup::Edge
          @sel_copy << _s if(!@sel_copy.include? _s)
          @edge << _s if((!@edge.include? _s)&&(_s.curve == nil))
        end
      end

      def main(lord)
        mq_cls_ins = MQInstance.new()

        @sel.each do |s|
          add_edge(s)
          mq_all_connected_a = s.all_connected
          if mq_all_connected_a.length == 1
            mq_cls_ins.new_edge(s) # initialize Line
          else
            if !s.is_a? Sketchup::Face
              mq_w_arccurve = s.curve
              if mq_w_arccurve != nil
                mq_first_e = mq_w_arccurve.first_edge
                mq_last_e = mq_w_arccurve.last_edge
                mq_start_ver = mq_first_e.vertices[0]
                mq_end_ver = mq_last_e.vertices[1]
                if mq_start_ver != mq_end_ver
                  mq_cls_ins.new_dotpair([mq_start_ver, mq_end_ver]) # initialize dot | curve
                end
              else
                mq_cls_ins.new_all_connected(mq_all_connected_a)
              end
            end
          end
        end

        mq_cls_ins.get_curve.each do |cool|; @curve << cool; end
        mq_cls_ins.get_cross.each do |cool|; @cross << cool; end

        mq_cls_point3d = MQPoint3d.new

        mq_cls_ins.get_vertex.each do |v|; mq_cls_point3d.new_vertex(v); end

        point3d_mq = mq_cls_point3d.gain_point3d

        mq_cls_vector = MQVector.new
        mq_cls_vector.point3d_mq = point3d_mq
        mq_cls_vector.initialize_mq_point3d
        mq_cls_vector.initialize_mq_patten
        mq_cls_vector.initialize_mq_point2d
        mq_cls_vector.dump_mq_point2d
        if lord == 1
          @line = mq_cls_vector.arrange_by_distance(@ent)
        elsif lord == 2
          @line = mq_cls_vector.arrange_by_phi(@ent)
        elsif lord == 3
          @line = mq_cls_vector.arrange_by_double_dis(@ent)
        else
          @line = mq_cls_vector.arrange_by_double_rad(@ent)
        end
      end

      def reselect()
        @sel_copy.each do |s|
          @sel.add s
        end
        @line.each do |l|
          @sel.add l if !l.deleted?
        end
      end

      def double_include(total, single)
        return true if (total.include?(single) || total.include?(single.reverse))
      end

      def restrict(float_len)
        if float_len == 0
          return
        end
        restriction = Array.new
        @line.each do |ed|
          if !ed.deleted?
            if !@edge.include?(ed)
              if ed.length > float_len
                restriction << ed
              end
            end
          end
        end
        if restriction.length != 0
          @ent.erase_entities(restriction)
        end
      end

      def eliminate(vertex_pairs)
        elimination = Array.new
        @line.each do |ed|
          if !ed.deleted?
            if !@edge.include?(ed)
              elimination << ed if double_include(vertex_pairs, ed.vertices)
            end
          end
        end
        @ent.erase_entities(elimination)
      end

      def start_operate()
        case @mode
        when 1
          str = "OuterConnect" # mode = 1 #=> no cross and curve connection
        when 2
          str = "CrossConnect" # mode = 2 #=> no curve connection
        when 3
          str = "CurveConnect" # mode = 3 #=> no cross connection
        else
          str = "NormalConnect"
        end
        @mod.start_operation(str, true) if @counter == 1
      end

      def execute(lord, limit)
        start_operate()
        main(lord)
        case @mode
        when 1
          eliminate(@cross)
          eliminate(@curve)
        when 2
          eliminate(@curve)
        when 3
          eliminate(@cross)
        end
        restrict(limit)
        reselect()
        @mod.commit_operation
        @counter >= 2 ? @counter = 1 : @counter += 1
      end
    end

    module MQEdgeConnect
      def MQEdgeConnect.mq_edge_connect(lord, mode, limit)
        edge_connection = MQEdgeConnectApi.new(mode)
        edge_connection.execute(lord, limit)
      end
    end

    def MessizQinEdgeConnect.messizqin_edge_connect(lord, mode, limit)
      MQEdgeConnect.mq_edge_connect(lord, mode, limit)
    end
  end

  module MessizQinEdgeSelect
    class MQEdgeSelect
      def initialize
        @mq_hash = Hash.new
        @x = Array.new
        @y = Array.new
        @z = Array.new
      end

      def get_p3d(ed)
        p1 = ed.vertices[0].position
        p2 = ed.vertices[1].position
        return p1, p2
      end

      def initialize_hash(ed, p1, p2)
        @x << p1[0]
        @y << p1[1]
        @z << p1[2]
        @x << p2[0]
        @y << p2[1]
        @z << p2[2]
        @mq_hash[ed] = [p1, p2]
      end

      def add_edge(mq_edge_a)
        if !@mq_hash.keys.include?(mq_edge_a)
          p1, p2 = get_p3d(mq_edge_a)
          initialize_hash(mq_edge_a, p1, p2)
        end
      end

      def frequency(arr)
        return arr.each_with_object(Hash.new(0)){|it, acc| acc[it] += 1}.max_by(&:last).first
      end

      def calc_patten()
        x_most = frequency(@x)
        y_most = frequency(@y)
        z_most = frequency(@z)
        x_count = @x.count(x_most)
        y_count = @y.count(y_most)
        z_count = @z.count(z_most)
        case [x_count, y_count, z_count].max
        when x_count
          return [0, x_most]
        when y_count
          return [1, y_most]
        when z_count
          return [2, z_most]
        end
      end

      def get_hash; @mq_hash; end
    end

    class MQSelectApi
      def initialize()
        @mod = Sketchup.active_model
        @ent = @mod.entities
        @sel = @mod.selection
        if @sel.empty?
          UI.messagebox("Please select the elements you want to connect")
          raise "No Selection"
        end
        @counter = 1
        @mod.start_operation("plane select", true) if @counter == 1
      end

      def get_patten()
        mq_es_cls = MQEdgeSelect.new
        @sel.each do |ed|
          if ed.is_a? Sketchup::Edge
            mq_es_cls.add_edge(ed)
          end
        end
        @mq_hash = mq_es_cls.get_hash
        @pt = mq_es_cls.calc_patten
      end

      def fit_patten(va, pat)
        p3d1 = va[0]
        p3d2 = va[1]
        indices = pat[0]
        co_va = pat[1]
        if p3d1[indices] == co_va && p3d2[indices] == co_va
          return true
        end
      end

      def get_edges()
        @edges = Array.new
        @mq_hash.each do |key, value|
          @edges << key if fit_patten(value, @pt)
        end
      end

      def reselect()
        @sel.clear
        @edges.each do |ed|
          @sel.add(ed)
        end
      end

      def execute()
        get_patten()
        get_edges()
        reselect()
        @mod.commit_operation
        @counter >= 2 ? @counter = 1 : @counter += 1
      end
    end


    module MQSelect
      def MQSelect.mq_select()
        mq_si_cls = MQSelectApi.new()
        mq_si_cls.execute
      end
    end

    def MessizQinEdgeSelect.messizqin_select
      MQSelect.mq_select
    end
  end


  module MessizQinCrossSplit
    class MQPointCollector
      def initialize()
        @mq_point3d = Array.new
        @mq_point2d = Array.new
        @x_arr = Array.new
        @y_arr = Array.new
        @z_arr = Array.new
      end

      def add_patten(p3d)
        @x_arr << p3d[0]
        @y_arr << p3d[1]
        @z_arr << p3d[2]
      end

      def edge_to_p3d(ed)
        p1 = ed.vertices[0].position
        p2 = ed.vertices[1].position
        add_patten(p1)
        add_patten(p2)
        return [p1, p2]
      end

      def add_edge(ed)
        @mq_point3d << edge_to_p3d(ed)
      end

      def calc_patten()
        if @x_arr.count(@x_arr[0]) == @x_arr.length
          @mq_patten = [[1, 2], @x_arr[0]]
        elsif @y_arr.count(@y_arr[0]) == @y_arr.length
          @mq_patten = [[0, 2], @y_arr[0]]
        elsif @z_arr.count(@z_arr[0]) == @z_arr.length
          @mq_patten = [[0, 1], @z_arr[0]]
        else
          UI.messagebox("Please select edges in the same plane")
          raise "Please select edges in the same plane"
        end
      end

      def p3d_to_p2d(p3d)
        return Geom::Point2d.new(p3d[@mq_patten[0][0]], p3d[@mq_patten[0][1]])
      end

      def initialize_p2d
        @mq_point3d.each do |p3d_pair|
          @mq_point2d << [p3d_to_p2d(p3d_pair[0]), p3d_to_p2d(p3d_pair[1])]
        end
      end

      def get_p2d; return @mq_point2d; end
      def get_patten; return @mq_patten; end
    end


    class MQEdgeIntersect
      def initialize()
        @main = Hash.new
      end

      def add_correspond(ed, pos)
        @main[ed] ||= Array.new
        @main[ed] << pos if !@main[ed].include? pos
      end

      def get_intersect(); @main; end
    end


    class MQCollector
      attr_accessor :mq_ei_cls

      def initialize()
        @mq_edge = Array.new
        @mq_fx = Array.new
        @mq_p2d = Array.new
        @mq_intersections = Array.new
      end

      def add_edge(ed)
        @mq_edge << ed
      end

      def add_p2d(p2d)
        @mq_p2d << p2d
        @mq_fx << ed_to_fx(p2d)
      end

      def ed_to_fx(p2d)
        a = p2d[0][0]
        b = p2d[0][1]
        n = p2d[1][0]
        m = p2d[1][1]
        if a != n && b != m
          k = (m - b) / (n - a.to_f)
          c = m - k * n
          return [k, c]
        else
          if a == n # vertical
            return [a, b, m, true]
          else # horizontal
            return [b, a, n, false]
          end
        end
      end

      def get_intersection(fx1, fx2)
        k1 = fx1[0]
        b1 = fx1[1]
        k2 = fx2[0]
        b2 = fx2[1]
        x = (b2 - b1) / (k1 - k2).to_f
        y = k1 * x + b1
        return [x, y]
      end

      def inrange(intersection, ind)
        dot_pair = @mq_p2d[ind]
        p1 = dot_pair[0]
        p2 = dot_pair[1]
        x1 = p1[0]
        y1 = p1[1]
        x2 = p2[0]
        y2 = p2[1]
        pc1 = [x1, x2, intersection[0]].sort
        pc2 = [y1, y2, intersection[1]].sort
        c1 = pc1[1] == intersection[0]
        c2 = pc2[1] == intersection[1]
        pc1.each do |pc|
          return false if pc1.count(pc) > 1
        end
        pc2.each do |pc|
          return false if pc2.count(pc) > 1
        end
        if c1 and c2
          return true
        end
      end

      def get_range(intersection, ind1, ind2)
        if(inrange(intersection, ind1) && inrange(intersection, ind2))
          mq_ei_cls.add_correspond(@mq_edge[ind1], intersection)
          mq_ei_cls.add_correspond(@mq_edge[ind2], intersection)
          return intersection
        end
      end

      def ninty_handle(ind1, ind2)
        fx1 = @mq_fx[ind1]
        fx2 = @mq_fx[ind2]

        def within(pv, la1, la2)
          arr = [la1, la2, pv]
          arr.each do |ar|
            if arr.count(ar) > 1
              return false
            end
          end
          return true if arr.sort[1] == pv
        end

        def get_y(x, k, b)
          return [x, k * x + b]
        end

        def get_x(y, k, b)
          return [(y - b) / k.to_f, y]
        end

        case fx1.length
        when 4
          case fx2.length
          when 4 # fx1[x, y, y, indicate] fx2 [y, x, x, indicate]
            if fx1[-1] != fx2[-1] # horizontal, vertical
              if (within(fx1[0], fx2[1], fx2[2]) && within(fx2[0], fx1[1], fx1[2]))
                h_inter = [fx2[0], fx1[0]]
                if fx1[-1]
                  h_inter.reverse!
                end
                mq_ei_cls.add_correspond(@mq_edge[ind1], h_inter)
                mq_ei_cls.add_correspond(@mq_edge[ind2], h_inter)
                return h_inter
              end
            end
          else # fx1[xy, xy, indicate] fx2 [k, c]
            if fx1[-1] # vertical [x, y, y]
              h_inter = get_y(fx1[0], fx2[0], fx2[1])
              if (within(h_inter[1], fx1[1], fx1[2]) && inrange(h_inter, ind2))
                mq_ei_cls.add_correspond(@mq_edge[ind1], h_inter)
                mq_ei_cls.add_correspond(@mq_edge[ind2], h_inter)
                return h_inter
              end
            else # horizontal [y, x, x]
              h_inter = get_x(fx1[0], fx2[0], fx2[1])
              if (within(h_inter[0], fx1[1], fx1[2]) && inrange(h_inter, ind2))
                mq_ei_cls.add_correspond(@mq_edge[ind1], h_inter)
                mq_ei_cls.add_correspond(@mq_edge[ind2], h_inter)
                return h_inter
              end
            end
          end
        else # fx1 [k, c] fx2 [xy, xy, indicate]
          if fx2[-1] # vertical [x, y, y]
            h_inter = get_y(fx2[0], fx1[0], fx1[1])
            if (inrange(h_inter, ind1) && within(h_inter[1], fx2[1], fx2[2]))
              mq_ei_cls.add_correspond(@mq_edge[ind1], h_inter)
              mq_ei_cls.add_correspond(@mq_edge[ind2], h_inter)
              return h_inter
            end
          else # horizontal [y, x, x]
            h_inter = get_x(fx2[0], fx1[0], fx1[1])
            if (inrange(h_inter, ind1) && within(h_inter[0], fx2[1], fx2[2]))
              mq_ei_cls.add_correspond(@mq_edge[ind1], h_inter)
              mq_ei_cls.add_correspond(@mq_edge[ind2], h_inter)
              return h_inter
            end
          end
        end
      end

      def intersect(ind1, ind2)
        if @mq_fx[ind1].length == 4 || @mq_fx[ind2].length == 4
          b_i = ninty_handle(ind1, ind2)
        else
          b_i = get_range(get_intersection(@mq_fx[ind1], @mq_fx[ind2]), ind1, ind2)
        end
        if b_i
          @mq_intersections << b_i
          return true
        end
      end

      def concatenate(array)
        result = []
        array.each_with_index do |d, i|
          (i+2..array.length).each do |ind|
            result << [array[i], array[ind - 1]]
          end
        end
        return result
      end

      def finalize()
        cross = Array.new
        @mq_p2d.each_with_index do |d, i|
          (i+2..@mq_p2d.length).each do |ind|
            if intersect(i, ind-1)
              cross << @mq_edge[i] if !cross.include?(@mq_edge[i])
              cross << @mq_edge[ind - 1] if !cross.include?(@mq_edge[ind - 1])
            end
          end
        end
        return cross
      end

      def finalinter(); @mq_intersections; end
    end


    class MQCrossApi
      def initialize()
        @mod = Sketchup.active_model # Open model
        @ent = @mod.entities # All entities in model
        @sel = @mod.selection # Current selection
        if @sel.empty?
          UI.messagebox("Please select the elements you want to connect")
          raise "No Selection"
        end
        @counter = 1
        @mod.start_operation("crossapi", true) if @counter == 1
      end

      def initialize_finalize(_finalize)
        @mq_finalize = _finalize
      end

      def initialize_finalsect(_finalsect)
        @mq_finalsect = _finalsect
      end

      def main_plus()
        mq_p3d_cls = MQPointCollector.new()
        mq_col_cls = MQCollector.new()
        mq_ei_cls = MQEdgeIntersect.new()
        mq_col_cls.mq_ei_cls = mq_ei_cls

        @sel.each do |ed|
          if ed.is_a? Sketchup::Edge
            if ed.curve == nil # plus
              mq_p3d_cls.add_edge(ed)
              mq_col_cls.add_edge(ed)
            end
          end
        end

        mq_p3d_cls.calc_patten
        mq_pt = mq_p3d_cls.get_patten
        @mq_patten = [[0, 1, 2] - mq_pt[0], mq_pt[1]]
        mq_p3d_cls.initialize_p2d
        mq_p2d_args = mq_p3d_cls.get_p2d

        mq_p2d_args.each do |p2d|
          mq_col_cls.add_p2d(p2d)
        end

        initialize_finalize(mq_col_cls.finalize)
        initialize_finalsect(mq_ei_cls.get_intersect)
      end

      def main_minus()
        mq_p3d_cls = MQPointCollector.new()
        mq_col_cls = MQCollector.new()
        mq_ei_cls = MQEdgeIntersect.new()
        mq_col_cls.mq_ei_cls = mq_ei_cls

        @sel.each do |ed|
          if ed.is_a? Sketchup::Edge
            # if ed.curve != nil # minus
            mq_p3d_cls.add_edge(ed)
            mq_col_cls.add_edge(ed)
          end
        end

        mq_p3d_cls.calc_patten
        mq_pt = mq_p3d_cls.get_patten
        @mq_patten = [[0, 1, 2] - mq_pt[0], mq_pt[1]]
        mq_p3d_cls.initialize_p2d
        mq_p2d_args = mq_p3d_cls.get_p2d

        mq_p2d_args.each do |p2d|
          mq_col_cls.add_p2d(p2d)
        end

        initialize_finalize(mq_col_cls.finalize)
        initialize_finalsect(mq_ei_cls.get_intersect)
      end

      def attr_finalize ;@mq_finalize; end
      def attr_finalsect; @mq_finalsect; end

      def execute_cross_delete_uncurve()
        main_minus()
        @mq_finalize.each do |ed|
          @ent.erase_entities(ed) if !ed.deleted?
        end
      end

      def execute_cross_delete_curve()
        main_plus()
        @mq_finalize.each do |ed|
          @ent.erase_entities(ed) if !ed.deleted?
        end
      end

      def advance_hash()
        @mq_finalsect.each do |key, value|
          new_value = Array.new
          value.each do |p2d|
            if p2d.length < 3
              v = p2d.insert(@mq_patten[0][0], @mq_patten[1])
            else
              v = p2d
            end
            new_value << Geom::Point3d.new(v)
          end
          @mq_finalsect[key] = new_value
        end
      end

      def sort_index(arg, arr)
        indices = 0
        arr.each do |ar|
          if arg < ar
            indices -= 1
          else
            indices += 1
          end
        end
        return indices
      end

      def sort_sequence(arr)
        indices = Hash.new
        arr.each do |arg|
          indices[sort_index(arg, arr)] = arg
        end
        _index = Array.new
        indices.sort.each do |ar|
          _index << ar[1]
        end
        return _index
      end

      def advanced_split(ed, p3ds)
        ed.explode_curve  if ed.curve != nil
        it = sort_sequence(p3ds).reverse
        it.each do |p3d|
          ed.split(p3d)
        end
      end

      def execute_cross_split_curve()
        main_minus()
        advance_hash()
        @mq_finalsect.each do |ed, pos_arr|
          advanced_split(ed, pos_arr)
        end
      end

      def execute(mode)
        case mode.to_f
        when 1
          execute_cross_delete_uncurve()
        when 2
          execute_cross_delete_curve()
        else
          execute_cross_split_curve()
        end
        @mod.commit_operation
        @counter >= 2 ? @counter = 1 : @counter += 1
      end
    end

    module MQCross
      def MQCross.mq_cross(mode)
        mq_cross = MQCrossApi.new()
        mq_cross.execute(mode)
      end
    end

    def MessizQinCrossSplit.messizqin_cross_split(mode2)
      MQCross.mq_cross(mode2.to_f)
    end
  end

  def MessizQinECPro.messizqin_select()
    MessizQinEdgeSelect.messizqin_select
  end

  def MessizQinECPro.set_mode(mode3)
    MQAttribute.replace_line(1, mode3)
  end

  def MessizQinECPro.messizqin_edge_connect()
    lord = MQAttribute.get_line(0).to_f
    mode = MQAttribute.get_line(1).to_f
    limit = MQAttribute.get_line(2).to_f
    MessizQinEdgeConnect.messizqin_edge_connect(lord, mode, limit)
  end

  def MessizQinECPro.messizqin_cross_split(mode2)
    MessizQinCrossSplit.messizqin_cross_split(mode2)
  end

  def MessizQinECPro.show_mode()
    lord = MQAttribute.get_line(0).to_f
    mode = MQAttribute.get_line(1).to_f
    limit = MQAttribute.get_line(2).to_f
    arr = Array.new
    case lord
    when 1
      arr << "<ALGORITHM: distance>"
      arr << "<METHOD: contineous>"
    when 2
      arr << "<ALGORITHM: radians>"
      arr << "<METHOD: contineous>"
    when 3
      arr << "<ALGORITHM: distance>"
      arr << "<METHOD: separate>"
    when 4
      arr << "<ALGORITHM: radians>"
      arr << "<METHOD: separate>"
    end
    case mode
    when 1
      arr << "<MODE: outline>"
    when 2
      arr << "<MODE: cross>"
    when 3
      arr << "<MODE: curve>"
    when 4
      arr << "<MODE: normal>"
    end
    case limit
    when 0
      arr << "<LIMIT: none>"
    else
      arr << "<LIMIT: set>"
    end
    str = arr.join(" || ")
    UI.messagebox(str)
  end

  def MessizQinECPro.replace_line(indices, arg)
    MQAttribute.replace_line(indices, arg)
  end

  def MessizQinECPro.set_limit()
    def MessizQinECPro.get_variable()
      quiz = ["Set maximun adding length as: "]
      default = [5.m]
      while true
        begin
          input = UI.inputbox(quiz, default)
          if input == false
            raise "Cancel Set Limit"
          elsif input[0].to_f <= 0
            UI.messagebox("Please entry a positive number. ")
          else
            return input[0].to_f
          end
        rescue TypeError
          UI.messagebox("Please entry a positive number. ")
        rescue ArgumentError
          UI.messagebox("Please entry a positive number. ")
        end
      end
    end
    MQAttribute.replace_line(2, MessizQinECPro.get_variable())
  end

  def MessizQinECPro.reset_limit()
    MQAttribute.replace_line(2, 0)
  end
end
